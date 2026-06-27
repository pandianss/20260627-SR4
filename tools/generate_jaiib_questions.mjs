// Bulk-generates JAIIB exam-style MCQs with Claude into the pipeline schema,
// deduped against the hand-authored bank, and writes
// content/raw/jaiib/questionBank_generated.js (merged by ingest_jaiib.mjs).
//
// Usage (needs an Anthropic API key with credit):
//   ANTHROPIC_API_KEY=sk-ant-... node tools/generate_jaiib_questions.mjs
//
// Options (env vars):
//   PER_PAPER=250     target questions per paper (default 250)
//   GEN_MODEL=claude-sonnet-4-6   model (default Sonnet 4.6 — cheap & accurate enough)
//   ONLY=PPB,AFM      restrict to certain papers
//
// After it finishes: `node tools/ingest_jaiib.mjs` then validate.

import Anthropic from '@anthropic-ai/sdk';
import { SUBJECTS, MODULES, TOPICS } from '../content/raw/jaiib/contentGraph.js';
import { QUESTION_BANK } from '../content/raw/jaiib/questionBank.js';
import { writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const OUT = resolve(__dirname, '../content/raw/jaiib/questionBank_generated.js');

const PER_PAPER = Number(process.env.PER_PAPER || 250);
const MODEL = process.env.GEN_MODEL || 'claude-sonnet-4-6';
const ONLY = (process.env.ONLY || '').split(',').map((s) => s.trim()).filter(Boolean);
const BATCH = 12; // questions requested per API call

const code = (subjId) => subjId.replace(/^p_/, '').toUpperCase(); // p_ppb -> PPB
const norm = (q) => String(q || '').toLowerCase().replace(/[^a-z0-9]/g, '').slice(0, 90);
const slug = (s) => String(s).toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '');

const client = new Anthropic(); // reads ANTHROPIC_API_KEY

const SCHEMA = {
  type: 'object',
  additionalProperties: false,
  properties: {
    questions: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        properties: {
          difficulty: { type: 'string', enum: ['Easy', 'Medium', 'High'] },
          q: { type: 'string' },
          opts: { type: 'array', items: { type: 'string' } },
          correct: { type: 'integer' },
          why: { type: 'string' },
        },
        required: ['difficulty', 'q', 'opts', 'correct', 'why'],
      },
    },
  },
  required: ['questions'],
};

function prompt(subjectName, moduleName, topicName, count, avoidStems) {
  const avoid = avoidStems.length
    ? `\nDo NOT repeat or closely paraphrase these existing questions:\n- ${avoidStems.slice(0, 25).join('\n- ')}`
    : '';
  return `You are an expert item-writer for the IIBF JAIIB examination (India).
Write ${count} multiple-choice questions for:
- Paper: ${subjectName}
- Module: ${moduleName}
- Topic: ${topicName}

Rules:
- India-specific and accurate to the current JAIIB syllabus and Indian banking regulation/practice.
- Each question has exactly 4 options and exactly ONE correct option; "correct" is the 0-based index.
- Distractors must be plausible (common misconceptions), not obviously wrong.
- Mix difficulties: roughly 40% Easy, 45% Medium, 15% High; include some numerical/applied items where the topic allows.
- "why" is a one- to two-sentence explanation of the correct answer.
- Prefer stable facts (definitions, rules, formulae, classifications) over volatile exact figures that change yearly; if you must cite a figure, pick a well-established one.
- No duplicates within this batch.${avoid}

Respond with the JSON object only.`;
}

async function genBatch(subjectName, moduleName, topicName, count, avoidStems) {
  const resp = await client.messages.create({
    model: MODEL,
    max_tokens: 4000,
    output_config: { format: { type: 'json_schema', schema: SCHEMA } },
    messages: [{ role: 'user', content: prompt(subjectName, moduleName, topicName, count, avoidStems) }],
  });
  const txt = (resp.content || []).find((b) => b.type === 'text')?.text || '{}';
  let parsed;
  try {
    parsed = JSON.parse(txt);
  } catch {
    return [];
  }
  return Array.isArray(parsed.questions) ? parsed.questions : [];
}

function valid(q) {
  return (
    q && typeof q.q === 'string' && q.q.trim() &&
    Array.isArray(q.opts) && q.opts.length === 4 && q.opts.every((o) => typeof o === 'string' && o.trim()) &&
    Number.isInteger(q.correct) && q.correct >= 0 && q.correct <= 3 &&
    typeof q.why === 'string' && q.why.trim()
  );
}

async function main() {
  if (!process.env.ANTHROPIC_API_KEY) {
    console.error('Set ANTHROPIC_API_KEY first.');
    process.exit(1);
  }

  // Seed dedup set with the hand-authored bank so we never duplicate it.
  const seen = new Set(QUESTION_BANK.map((q) => norm(q.q)));
  const out = [];

  for (const subj of SUBJECTS) {
    const subjCode = code(subj.id);
    if (ONLY.length && !ONLY.includes(subjCode)) continue;

    // Topics across this paper's modules.
    const topics = [];
    for (const m of MODULES[subj.id] || []) {
      for (const t of TOPICS[m.id] || []) topics.push({ module: m, topic: t });
    }
    if (!topics.length) continue;

    const existingForPaper = QUESTION_BANK.filter((q) => q.subjectId === subjCode).length;
    const target = Math.max(0, PER_PAPER - existingForPaper);
    const perTopic = Math.ceil(target / topics.length);
    let produced = 0;
    const counters = {};
    console.log(`\n=== ${subjCode}: have ${existingForPaper}, generating ~${target} across ${topics.length} topics ===`);

    for (const { module, topic } of topics) {
      if (produced >= target) break;
      let made = 0;
      const localStems = [];
      let guard = 0;
      while (made < perTopic && produced < target && guard < 10) {
        guard++;
        const want = Math.min(BATCH, perTopic - made);
        let batch;
        try {
          batch = await genBatch(subj.name, module.name, topic.name, want, localStems);
        } catch (e) {
          console.error(`  ! ${topic.id}: API error ${e.message} — skipping`);
          break;
        }
        let added = 0;
        for (const q of batch) {
          if (!valid(q)) continue;
          const key = norm(q.q);
          if (seen.has(key)) continue;
          seen.add(key);
          counters[topic.id] = (counters[topic.id] || 0) + 1;
          out.push({
            id: `g_${subjCode.toLowerCase()}_${slug(topic.id)}_${counters[topic.id]}`,
            subjectId: subjCode,
            topicId: topic.id,
            difficulty: q.difficulty,
            q: q.q.trim(),
            opts: q.opts.map((o) => o.trim()),
            correct: q.correct,
            why: q.why.trim(),
          });
          localStems.push(q.q.trim());
          made++; produced++; added++;
          if (made >= perTopic || produced >= target) break;
        }
        if (added === 0) break; // model dried up for this topic
      }
      console.log(`  ${topic.id}: +${made} (paper total ${produced}/${target})`);
    }
  }

  const banner = '// AUTO-GENERATED by tools/generate_jaiib_questions.mjs — do not hand-edit.\n' +
    '// Run the generator to (re)populate this file. Merged into the pack by\n' +
    '// tools/ingest_jaiib.mjs alongside the hand-authored QUESTION_BANK.\n';
  writeFileSync(OUT, `${banner}export const GENERATED_QUESTIONS = ${JSON.stringify(out, null, 2)};\n`);
  console.log(`\nWrote ${out.length} generated questions -> ${OUT}`);
  console.log('Next: node tools/ingest_jaiib.mjs  &&  dart run packages/domain/bin/validate_pack.dart packages/app/assets/content_pack_jaiib.json');
}

main();
