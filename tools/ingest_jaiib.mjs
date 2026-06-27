// Transforms the raw JAIIB authoring data (content/raw/jaiib/*.js) into a
// content pack in the engine schema (same shape the Dart compiler emits),
// written to packages/app/assets/content_pack_jaiib.json.
//
// Run: node tools/ingest_jaiib.mjs
// Validate afterwards: dart run packages/domain/bin/validate_pack.dart <pack>

import { SUBJECTS, MODULES, TOPICS } from '../content/raw/jaiib/contentGraph.js';
import { MICRO_LESSONS } from '../content/raw/jaiib/microLessons.js';
import { QUESTION_BANK } from '../content/raw/jaiib/questionBank.js';
import { GENERATED_QUESTIONS } from '../content/raw/jaiib/questionBank_generated.js';
import { writeFileSync, mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const OUT = resolve(__dirname, '../packages/app/assets/content_pack_jaiib.json');

const L = (en) => ({ en: String(en ?? '').trim() });
const text = (en) => ({ kind: 'text', md: L(en) });
const letter = (i) => String.fromCharCode(97 + i); // 0 -> 'a'
const DIFF = { Easy: 1, Medium: 2, High: 3, Critical: 4, Hard: 4 };
const diff = (d) => DIFF[d] ?? 2;

// topic id -> module id
const topicToModule = {};
for (const [moduleId, topics] of Object.entries(TOPICS)) {
  for (const t of topics) topicToModule[t.id] = moduleId;
}

const subjects = SUBJECTS.map((s) => ({ ...s, kind: 'compulsory' }));

const exam = {
  id: 'ex_jaiib',
  code: 'JAIIB',
  name: 'JAIIB Certification',
  body: 'Indian Institute of Banking and Finance',
  languages: ['en'],
  configId: '',
  paperIds: subjects.map((s) => s.id),
  status: 'published',
  version: 1,
};

const papers = subjects.map((s) => ({
  id: s.id,
  examCode: 'JAIIB',
  name: L(s.name),
  kind: s.kind,
  moduleIds: (MODULES[s.id] || []).map((m) => m.id),
}));

const questions = [];
const lessons = [];
const lessonsByModule = {};
const seenQ = new Set();
let skippedLessons = 0;
let skippedQuestions = 0;

function makeQuestion(id, topicId, subjectId, difficulty, q, opts, correct, why) {
  if (!Array.isArray(opts) || opts.length < 2) return null;
  if (typeof correct !== 'number' || correct < 0 || correct >= opts.length) return null;
  const stem = String(q ?? '').trim();
  if (!stem) return null;
  return {
    id,
    version: 1,
    topicTags: [topicId, subjectId].filter(Boolean),
    difficulty,
    gradingMode: 'auto_exact',
    defaultMarks: 1,
    defaultNegativeMarks: 0,
    explanation: L(why && String(why).trim() ? why : 'Review the related concept card.'),
    authoring: { status: 'published', authorId: 'jaiib_ingest', reviewerId: 'jaiib_review' },
    payload: {
      type: 'mcq_single',
      stem: L(stem),
      options: opts.map((o, i) => ({ id: letter(i), content: L(o) })),
      correctOptionId: letter(correct),
    },
  };
}

function pillarsMd(step) {
  const items = (step.pillars || []).map((p) => `- **${p.n}** — ${p.d}`).join('\n');
  return `**${step.title}**\n\n${items}`;
}
function scenarioMd(step) {
  const steps = (step.steps || []).map((s) => `- ${s}`).join('\n');
  return [`**${step.title}**`, step.problem, steps, step.verdict || '']
    .filter((s) => s && String(s).trim())
    .join('\n\n');
}

for (const ml of MICRO_LESSONS) {
  const moduleId = topicToModule[ml.topicId];
  if (!moduleId) { skippedLessons++; continue; }

  const cards = [];
  let ci = 0;
  cards.push({
    id: `${ml.id}-c${ci++}`,
    kind: 'intro',
    srsEligible: false,
    blocks: [text(`**${ml.title}**${ml.badge ? `\n\n${ml.badge}` : ''}`)],
  });

  const probeIds = [];
  let qi = 0;
  for (const step of ml.steps || []) {
    if (step.kind === 'concept') {
      const blocks = [text(`**${step.title}**\n\n${step.body}`)];
      if (step.highlight) blocks.push(text(`**Key:** ${step.highlight}`));
      cards.push({ id: `${ml.id}-c${ci++}`, kind: 'concept', srsEligible: true, blocks });
    } else if (step.kind === 'pillars') {
      cards.push({ id: `${ml.id}-c${ci++}`, kind: 'concept', srsEligible: false, blocks: [text(pillarsMd(step))] });
    } else if (step.kind === 'scenario') {
      cards.push({ id: `${ml.id}-c${ci++}`, kind: 'example', srsEligible: true, blocks: [text(scenarioMd(step))] });
    } else if (step.kind === 'quiz') {
      const qid = `${ml.id}-quiz${qi === 0 ? '' : qi + 1}`;
      const question = makeQuestion(qid, ml.topicId, ml.subjectId, 2, step.question, step.opts, step.correct, step.why);
      if (question && !seenQ.has(qid)) {
        seenQ.add(qid);
        questions.push(question);
        probeIds.push(qid);
        qi++;
      }
    }
  }

  if (probeIds.length === 0) { skippedLessons++; continue; }

  const est = parseInt(String(ml.time ?? '3'), 10) || 3;
  lessons.push({
    id: ml.id,
    moduleId,
    title: L(ml.title),
    estMinutes: est,
    version: 1,
    cards,
    probeQuestionIds: probeIds,
  });
  (lessonsByModule[moduleId] ||= []).push(ml.id);
}

for (const bq of [...QUESTION_BANK, ...GENERATED_QUESTIONS]) {
  if (seenQ.has(bq.id)) continue;
  const question = makeQuestion(bq.id, bq.topicId, bq.subjectId, diff(bq.difficulty), bq.q, bq.opts, bq.correct, bq.why);
  if (!question) { skippedQuestions++; continue; }
  seenQ.add(bq.id);
  questions.push(question);
}

const modules = [];
for (const s of subjects) {
  for (const m of MODULES[s.id] || []) {
    modules.push({
      id: m.id,
      paperId: s.id,
      name: L(m.name),
      topicTags: (TOPICS[m.id] || []).map((t) => t.id),
      lessonIds: lessonsByModule[m.id] || [],
    });
  }
}

const pack = { exams: [exam], papers, modules, lessons, questions, assets: [], stimuli: [] };

mkdirSync(dirname(OUT), { recursive: true });
writeFileSync(OUT, JSON.stringify(pack, null, 2));

console.log(`JAIIB content pack -> ${OUT}`);
console.log(`  exams=${pack.exams.length} papers=${papers.length} modules=${modules.length} lessons=${lessons.length} questions=${questions.length}`);
console.log(`  skipped: lessons=${skippedLessons} questions=${skippedQuestions}`);
