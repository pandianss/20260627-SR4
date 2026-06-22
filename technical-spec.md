# Technical Specification — Multi-Exam Micro-Learning Engine

*Companion to [banking-microlearning-study.md](banking-microlearning-study.md) §6. This document specifies the content schema, the polymorphic question-type system, the declarative exam-configuration format, the spaced-repetition (SRS) data model, the assessment/mock engine, and the offline-first sync protocol.*

**Design goal:** build the engine **once**; add an exam by authoring a **content pack** + writing one **exam-config file** — no engine code changes. The hardest variation across exams is **question format**, so the question-type system is designed first and given the most room.

> **Scope (current focus): the IIBF professional-certification family** — JAIIB and CAIIB (flagship), plus the specialized certificates/diplomas working bankers take to upskill (International Banking, Risk Management, Credit, Treasury, AML/KYC, Banking Compliance, Trade Finance, Foreign Exchange, …). These exams are unusually **homogeneous**: almost all are **100 objective MCQs including case-study/caselet questions · 2 hours · 50% to pass · no negative marking · multilingual (English/Hindi + regional)**. Consequences for this build: (1) per-exam **config is nearly uniform** — adding a certification is ~90% content authoring + translation, ~10% config; (2) the **descriptive-answer family (§4.2) and assisted grading (§5) are out of the critical path** (these exams are objective MCQ — keep the capability in the engine for future descriptive exams, but don't build it now); (3) the **case-study/caselet** is the signature format to nail (§4.4); (4) **localization is P0**, not a later add. The broader multi-exam capability described below still holds — it's simply not the current content target.

Schemas are shown as TypeScript interfaces (discriminated unions) for precision; they map 1:1 to JSON for storage/transport and to SQL tables in §10.

---

## 1. Design principles

1. **Polymorphic by format, uniform by interface.** Every question, whatever its format, implements a common envelope (`QuestionBase`) and a type-specific `payload`. The renderer and grader dispatch on a single `type` discriminant. Adding a new format = add one payload type + one grader + one renderer; nothing else changes.
2. **Grading is a strategy, not an `if/else`.** Each question type declares a `gradingMode`. Auto-gradable types grade deterministically on-device *and* server; descriptive types route to an AI-assisted + human-review pipeline. This single axis cleanly separates objective exams (JAIIB, IBPS prelims) from descriptive ones (RBI GB Phase 2, NABARD Phase 2, SEBI descriptive).
3. **Config is declarative and data, not code.** Marking schemes, negative marking, sectional timing, pass rules, language, and mock blueprints live in a versioned JSON config per exam. The engine *reads* exam rules; it never hard-codes them.
4. **Offline-first.** Content packs + SRS state + a learner's answer events live in a local store; the device is the source of truth between syncs. Only descriptive grading and leaderboards require connectivity.
5. **Content is shared, not duplicated.** A question is tagged to topics, not bound to one exam. Quant/reasoning/English/ESI/GA items are reused across RBI/NABARD/SEBI/IBPS via tags + blueprints.
6. **Event-sourced learning history.** Every answer/review is an append-only event. SRS state and analytics are projections. This makes sync conflict-free and analytics replayable.

---

## 2. Architecture overview

```
┌────────────────────────── MOBILE CLIENT (Flutter — see §15) ─────────────────────┐
│  Renderers (per question type)   Lesson player   Mock player   Review (SRS) queue │
│  Local store (SQLite): content packs · SRS state · event log · sync cursor        │
│  On-device graders (auto types)   ·   Scheduler (computes due queue)              │
└───────────────▲───────────────────────────────────────────────▲──────────────────┘
                │ content pack pull (versioned)                  │ event push / pull (sync)
┌───────────────┴───────────────────────────────────────────────┴──────────────────┐
│  API GATEWAY (REST/GraphQL, token auth)                                            │
├───────────────────────────────────────────────────────────────────────────────────┤
│  Content Service │ Exam-Config Service │ Sync Service │ SRS Projector │ Mock Service │
│  Grading Service (auto + AI-assisted/descriptive + human-review queue)              │
│  Analytics pipeline (event consumer)   Notification trigger service                 │
├───────────────────────────────────────────────────────────────────────────────────┤
│  Headless CMS (SME authoring + validation + review workflow + versioning)           │
├───────────────────────────────────────────────────────────────────────────────────┤
│  Stores: Content DB · Exam-Config DB · Event store · User/SRS DB · Object store(assets)│
└───────────────────────────────────────────────────────────────────────────────────┘
```

**Build the Content schema + Question-type system + SRS state model first** (§3, §4, §7). They are the moat and the hardest to change later; everything else (UI, notifications, leaderboards) is replaceable.

---

## 3. Content domain model

### 3.1 Hierarchy

```
Exam ─┬─ Paper ─┬─ Module ─┬─ Lesson ─┬─ Card[]            (teaching: micro-content)
      │         │          │          └─ probe Question[]  (retrieval at lesson end)
      │         │          └─ Topic tags (cross-exam reuse key)
      │         └─ (Elective papers attach here, e.g. CAIIB)
      └─ ExamConfig (declarative rules — §6)

QuestionBank ── Question[]  (tagged to Topics; reused by Lessons AND Mocks)
Stimulus[]  ── shared passages/charts/caselets referenced by Question sets
Asset[]     ── images, animations, audio, charts (object store, referenced by id)
```

Lessons reference questions **by id** from the shared `QuestionBank` (a question can be a lesson probe *and* appear in mocks). Passage/DI/caselet questions reference a shared `Stimulus` so the passage isn't duplicated and the set is timed/scored coherently.

### 3.2 Core entities

```ts
type ID = string;          // ULID
type LangCode = 'en' | 'hi' | string;

interface Exam {
  id: ID;
  code: string;            // 'JAIIB' | 'CAIIB' | 'RBI_GRADE_B' | 'NABARD_GRADE_A' | 'SEBI_GRADE_A' | 'IBPS_PO' ...
  name: string;
  body: 'IIBF' | 'RBI' | 'NABARD' | 'SEBI' | 'IBPS' | 'SBI';
  languages: LangCode[];
  configId: ID;            // -> ExamConfig (§6)
  paperIds: ID[];
  status: 'draft' | 'published';
  version: number;
}

interface Paper {
  id: ID; examCode: string;
  name: string;            // 'Principles & Practices of Banking'
  kind: 'compulsory' | 'elective';
  moduleIds: ID[];
}

interface Module {
  id: ID; paperId: ID;
  name: string;
  topicTags: string[];     // e.g. ['quant.data_interpretation','english.rc'] — reuse key
  lessonIds: ID[];
}

interface Lesson {
  id: ID; moduleId: ID;
  title: string;
  estMinutes: number;      // target <= 5
  cards: Card[];           // teaching content
  probeQuestionIds: ID[];  // end-of-lesson retrieval, from QuestionBank
  version: number;
}

interface Card {
  id: ID;
  kind: 'intro' | 'concept' | 'example' | 'recap';
  blocks: ContentBlock[];  // rich content (text, image, animation, formula, chart)
  // Each concept Card is the unit that becomes a long-term SRS "LearnableItem" (§7)
  srsEligible: boolean;
}

type ContentBlock =
  | { kind: 'text'; md: string }
  | { kind: 'image' | 'animation' | 'audio'; assetId: ID; alt: string }
  | { kind: 'formula'; latex: string }
  | { kind: 'chart'; spec: object };   // vega-lite-style spec, rendered client-side
```

All learner-facing strings (`name`, `md`, `alt`, option text, explanations) are **localizable**: stored as `Record<LangCode, string>` in the DB; shown here as `string` for brevity. See §12.4.

---

## 4. The Question-Type System  *(the core)*

Different exams use materially different question formats. The system models this as **one envelope + a discriminated-union payload**, plus a **separate grading axis**.

### 4.1 The envelope (common to every type)

```ts
interface QuestionBase {
  id: ID;
  version: number;
  topicTags: string[];           // reuse + blueprint selection key
  difficulty: number;            // 1..5 authored; refined by IRT/usage (§7.6)
  gradingMode: GradingMode;      // see §5 — derived from type but overridable
  defaultMarks: number;          // overridden by section/mock config (§6)
  defaultNegativeMarks: number;  // 0 for JAIIB/CAIIB; e.g. 0.25 for IBPS; set by config
  explanation: LocalizedRich;    // shown post-answer (critical for learning)
  sourceRef?: string;            // syllabus/citation anchor
  stimulusId?: ID;               // set when part of a passage/DI/caselet SET (§4.4)
  authoring: { status: 'draft'|'in_review'|'published'; authorId: ID; reviewerId?: ID };
  payload: QuestionPayload;      // discriminated union below
}

type GradingMode =
  | 'auto_exact'        // deterministic equality/set/sequence
  | 'auto_numeric'      // value within tolerance
  | 'auto_text'         // normalized string match (fill-blank)
  | 'assisted_rubric'   // AI scores against rubric; human can review (descriptive)
  | 'manual';           // human-only (rare; high-stakes essays if AI disabled)
```

### 4.2 The payload union — every supported format

```ts
type QuestionPayload =
  | MCQSingle | MCQMulti | TrueFalse | AssertionReason
  | FillBlank | Cloze
  | NumericEntry | NumericMultiStep
  | MatchPairs | Ordering
  | DescriptiveShort | Essay | Precis | Comprehension   // free-text family
  | PassageRef;                                          // a sub-question inside a SET
```

**Objective / auto-gradable**

```ts
interface MCQSingle  { type:'mcq_single'; stem:LocalizedRich; options:Option[]; correctOptionId:ID; }
interface MCQMulti   { type:'mcq_multi'; stem:LocalizedRich; options:Option[]; correctOptionIds:ID[];
                       partialCredit: 'none'|'per_correct'|'jaccard'; }
interface TrueFalse  { type:'true_false'; stem:LocalizedRich; answer:boolean; }
interface AssertionReason {
  type:'assertion_reason'; assertion:LocalizedRich; reason:LocalizedRich;
  options:Option[]; correctOptionId:ID;            // standard A–E "both true & R explains A" set
}
interface Option { id:ID; content:LocalizedRich; }

interface FillBlank {
  type:'fill_blank'; template:LocalizedRich;       // 'CRR is held with the ___'
  blanks: { id:ID; accepted:string[]; normalize:NormalizeRule[] }[];
}
interface Cloze {                                  // English: passage with N inline blanks
  type:'cloze'; passage:LocalizedRich;
  blanks: { id:ID; options?:Option[]; accepted?:string[]; correctOptionId?:ID }[];
}

interface NumericEntry {                           // quant / accounting / financial math
  type:'numeric'; stem:LocalizedRich;
  answer:{ value:number; unit?:string };
  tolerance:{ kind:'absolute'|'relative'|'decimals'; amount:number };
}
interface NumericMultiStep {                        // Brilliant-style guided workout (optional)
  type:'numeric_multistep'; stem:LocalizedRich;
  steps:{ id:ID; prompt:LocalizedRich; answer:number; tolerance:number; hint?:LocalizedRich }[];
}

interface MatchPairs {
  type:'match_pairs'; stem:LocalizedRich;
  left:Option[]; right:Option[]; correct:Record<ID,ID>;   // leftId -> rightId
  partialCredit:'none'|'per_pair';
}
interface Ordering {
  type:'ordering'; stem:LocalizedRich; items:Option[]; correctOrder:ID[];
  partialCredit:'none'|'kendall_tau'|'longest_increasing';
}
```

**Free-text / descriptive (RBI GB Phase 2, NABARD Phase 2, SEBI descriptive)**

```ts
interface DescriptiveShort {
  type:'descriptive_short'; stem:LocalizedRich;
  wordLimit?:{min:number;max:number}; rubric:RubricCriterion[]; modelAnswer?:LocalizedRich;
}
interface Essay {                                  // RBI GB / NABARD essay
  type:'essay'; prompt:LocalizedRich;
  wordLimit:{min:number;max:number}; rubric:RubricCriterion[];
}
interface Precis  { type:'precis'; passage:LocalizedRich; targetWords:number; rubric:RubricCriterion[]; }
interface Comprehension {                          // descriptive comprehension (subjective answers)
  type:'comprehension'; passage:LocalizedRich;
  questions:{ id:ID; prompt:LocalizedRich; rubric:RubricCriterion[] }[];
}
interface RubricCriterion { id:ID; label:string; maxScore:number; guidance:string; }
```

### 4.3 Why this covers the exam family

| Format | Type(s) | Seen in |
|---|---|---|
| Single-best-answer MCQ | `mcq_single` | JAIIB, CAIIB, IBPS/SBI, RBI/NABARD/SEBI Phase 1 |
| Multi-select / T-F / Assertion-Reason | `mcq_multi`, `true_false`, `assertion_reason` | CAIIB, GA sections |
| Fill-in / Cloze | `fill_blank`, `cloze` | English sections |
| Numeric (calc) | `numeric`, `numeric_multistep` | Quant, BFM, Accounting & Financial Mgmt |
| Match / Ordering | `match_pairs`, `ordering` | reasoning, process/sequence items |
| Reading Comp / Data Interpretation / Caselet | **`PassageRef` + Stimulus set** (§4.4) | English RC, Quant DI, ESI caselets |
| Essay / Précis / Descriptive comprehension | `essay`, `precis`, `comprehension`, `descriptive_short` | **RBI GB Phase 2, NABARD Phase 2, SEBI descriptive** |

New format later (e.g. speaking, or a novel puzzle)? Add a payload + grader + renderer. The envelope, config, SRS, sync, and analytics are untouched.

### 4.4 Composite SETS — passages, DI, caselets

Reading Comprehension, Data Interpretation, and caselets share **one stimulus across several questions**, and must be **timed and presented as a unit**. Model the stimulus separately; sub-questions reference it.

```ts
interface Stimulus {
  id:ID;
  kind:'passage'|'chart'|'table'|'caselet';
  content:LocalizedRich;          // passage text, or
  asset?:ID; chartSpec?:object;   // chart/table data
  childQuestionIds:ID[];          // ordered sub-questions
}
interface PassageRef {            // the payload a sub-question carries
  type:'passage_ref';
  innerType:'mcq_single'|'mcq_multi'|'numeric'|'descriptive_short';
  inner: MCQSingle | MCQMulti | NumericEntry | DescriptiveShort;  // the actual question, sans stimulus
}
```

A DI set = one `Stimulus{kind:'chart'}` + N questions whose payload is `passage_ref → numeric/mcq_single`. The mock player renders the stimulus once with its children; scoring sums children but the **set is the timing/SRS unit**.

---

## 5. Grading & scoring engine

A **grader registry** maps `(type, gradingMode)` → grader function. Auto graders run on-device (offline) and server-side (authoritative); assisted/manual run server-side only.

```ts
interface GradeResult {
  score:number;            // marks awarded (can be negative if negative marking applied)
  maxScore:number;
  correctness:'correct'|'partial'|'incorrect'|'pending';   // 'pending' => awaiting assisted/manual
  perPart?:Record<ID,number>;                              // blanks, pairs, set children
  feedback?:LocalizedRich;
}

type Grader = (q:QuestionBase, response:Response, ctx:GradingContext) => GradeResult;
```

**Auto graders (deterministic, offline-capable):**
- `mcq_single`/`true_false`/`assertion_reason`: equality on option id.
- `mcq_multi`: set equality; or partial via `per_correct` / Jaccard per `partialCredit`.
- `numeric`: `|given − answer| ≤ tolerance` (abs/relative/decimals); unit check.
- `fill_blank`/`cloze`: normalize (case/whitespace/synonyms/number words) then match `accepted`.
- `match_pairs`: mapping equality; partial `per_pair`. `ordering`: sequence equality; partial via Kendall-tau.

**Assisted graders (descriptive — online):**
- `essay`/`precis`/`descriptive_short`/`comprehension`: an LLM scores the response **against the rubric criteria** (per-criterion scores + feedback), constrained to the rubric and (if present) model answer. Output is `correctness:'pending'→` final once scored; **flagged for human review** above a confidence threshold or on appeal. Never let raw AI be the silent source of truth for a high-stakes mark — rubric-bounded + reviewable (see study §11 risk note).

**Marking-scheme application (from config, §6):** the engine applies `marks` / `negativeMarks` **from the section/mock config**, not the question's defaults, so the *same* question scores differently in a JAIIB lesson (no negative marking) vs. an IBPS mock (−0.25). Unanswered = 0 (no negative). Partial-credit policy is per-type but capped by config (some exams forbid partial credit — config can force `all_or_nothing`).

```ts
function applyMarking(raw:GradeResult, rule:MarkingRule, answered:boolean):GradeResult {
  if (!answered) return {...raw, score:0};
  if (raw.correctness==='incorrect') return {...raw, score: -rule.negativeMarks};
  if (raw.correctness==='partial' && !rule.allowPartial)
      return {...raw, score:0, correctness:'incorrect'};
  return {...raw, score: raw.score * rule.marksScale};
}
```

---

## 6. Exam-configuration format  *(declarative — the "add an exam without code" layer)*

One JSON document per exam captures **everything that varies**: paper/section structure, allowed question types, marking, **negative marking**, **sectional vs overall timing**, **pass rules**, languages, and the **mock blueprint**.

```ts
interface ExamConfig {
  examCode:string; version:number; languages:LangCode[];
  papers:PaperConfig[];
  passRule:PassRule;
  mockBlueprints:MockBlueprint[];
  gradingProfile:{ allowPartialDefault:boolean; descriptiveGrading:'assisted'|'manual'|'off' };
}

interface PaperConfig {
  paperCode:string; name:string;
  durationMin:number; sectionalTiming:boolean;      // RBI/SBI may lock sections individually
  sections:SectionConfig[];
}
interface SectionConfig {
  code:string; name:string;
  allowedTypes:QuestionType[];                       // which formats appear here
  count:number; marksPerQuestion:number; negativeMarks:number;
  durationMin?:number;                               // present iff sectionalTiming
  cutoff?:number;                                    // sectional qualifying cutoff
}
interface PassRule {
  perComponentMin?:number;                           // e.g. JAIIB 50/100 each paper
  alternativeAggregate?:{ perComponentMin:number; aggregateMin:number }; // JAIIB 45 each + 50% agg
  overallMin?:number; carryForward?:boolean;         // IIBF subject carry-forward across attempts
}
interface MockBlueprint {
  id:string; name:string;                            // 'Full Mock' | 'Sectional: Quant' | 'Daily Quiz'
  picks:{ topicTags:string[]; count:number; difficultyMix:Record<1|2|3|4|5, number> }[];
  shuffle:boolean; timingFromPaper?:string;
}
```

### 6.1 Plug-in examples (the IIBF family — near-uniform config, different content + the caselet format)

**JAIIB — objective, no negative marking, two-path pass rule, multilingual:**
```json
{ "examCode":"JAIIB", "languages":["en","hi","mr","ta","te","kn","gu","bn","ml","or","as"],
  "papers":[{ "paperCode":"PPB","name":"Principles & Practices of Banking",
    "durationMin":120, "sectionalTiming":false,
    "sections":[{ "code":"ALL","name":"MCQ + caselets",
      "allowedTypes":["mcq_single","true_false","match_pairs","passage_ref"],
      "count":100, "marksPerQuestion":1, "negativeMarks":0 }] }],
  "passRule":{ "perComponentMin":50,
    "alternativeAggregate":{ "perComponentMin":45, "aggregateMin":50 }, "carryForward":true },
  "gradingProfile":{ "allowPartialDefault":false, "descriptiveGrading":"off" } }
```

**CAIIB — same shell + a learner-chosen elective (1 of N):**
```json
{ "examCode":"CAIIB", "languages":["en","hi"],
  "papers":[
    { "paperCode":"ABM","name":"Advanced Bank Management","kind":"compulsory","durationMin":120,
      "sections":[{ "code":"ALL","allowedTypes":["mcq_single","numeric","passage_ref"],
        "count":100,"marksPerQuestion":1,"negativeMarks":0 }] },
    { "paperCode":"ELECTIVE","name":"Elective (choose 1)","kind":"elective",
      "electiveOptions":["RISK_MGMT","INTL_BANKING","RURAL_BANKING","CENTRAL_BANKING","HRM","IT"],
      "durationMin":120,
      "sections":[{ "code":"ALL","allowedTypes":["mcq_single","numeric","passage_ref"],
        "count":100,"marksPerQuestion":1,"negativeMarks":0 }] }],
  "passRule":{ "perComponentMin":50,
    "alternativeAggregate":{ "perComponentMin":45, "aggregateMin":50 }, "carryForward":true },
  "gradingProfile":{ "allowPartialDefault":false, "descriptiveGrading":"off" } }
```

**A specialized certificate (e.g. Risk in Financial Services / International Banking) — *same shell*, new content pack:**
```json
{ "examCode":"CERT_RISK", "languages":["en","hi"],
  "papers":[{ "paperCode":"SINGLE","name":"Risk in Financial Services","durationMin":120,
    "sections":[{ "code":"ALL","name":"MCQ + caselets",
      "allowedTypes":["mcq_single","numeric","passage_ref"],
      "count":100,"marksPerQuestion":1,"negativeMarks":0 }] }],
  "passRule":{ "perComponentMin":50 },
  "gradingProfile":{ "allowPartialDefault":false, "descriptiveGrading":"off" } }
```

Because the IIBF format is so consistent, **adding a certification is ~90% content authoring + translation, ~10% config.** The one format that must be excellent is the **case-study / caselet**: a scenario stimulus followed by several application MCQs, modeled as a `Stimulus{kind:'caselet'}` + `passage_ref` children (§4.4). Content reuse is high — *International Banking* and *Risk Management* exist as **both CAIIB electives and standalone certificates**, so a topic pack authored once serves multiple certifications.

---

## 7. Spaced-repetition (SRS) data model & scheduler

### 7.1 What gets scheduled

The SRS schedules **retrieval events** against **LearnableItems**. A LearnableItem wraps either a concept `Card` (knowledge to retain) bound to one or more *probe* questions, or a standalone `Question`. State is per **(user, item)**.

```ts
interface LearnableItem {
  id:ID;
  kind:'card'|'question';
  refId:ID;                 // Card.id or Question.id
  probeQuestionIds:ID[];    // for cards: how to test recall (rotate to avoid memorizing one Q)
  topicTags:string[];
  examContexts:string[];    // which exams this item serves
}

interface SrsState {
  userId:ID; itemId:ID;
  algo:'fsrs'|'sm2';
  // FSRS-style memory model (recommended):
  stability:number;         // days; expected retention horizon
  difficulty:number;        // 1..10 item difficulty for this user
  dueAt:number;             // epoch ms
  lastReviewedAt:number;
  reps:number; lapses:number;
  state:'new'|'learning'|'review'|'relearning'|'mastered'|'suspended';
  examContext:string;       // active exam-cycle scoping
}
```

### 7.2 Algorithm — FSRS, pluggable

Use **FSRS** (modern, outperforms SM-2) behind an interface so it can be swapped/tuned. On each review the learner produces a grade; for objective probes derive it from correctness + latency, for descriptive use the rubric score band:

```ts
type Rating = 'again'|'hard'|'good'|'easy';   // 1..4

function review(state:SrsState, rating:Rating, now:number):SrsState {
  const next = fsrs.next(state, rating, now);          // updates stability, difficulty
  return { ...state,
    stability: next.stability, difficulty: next.difficulty,
    reps: state.reps + 1,
    lapses: rating==='again' ? state.lapses+1 : state.lapses,
    lastReviewedAt: now,
    dueAt: clampToExam(now + next.intervalDays*DAY, state.examContext),  // §7.4
    state: deriveState(next) };
}
```

Initial intervals follow the evidence base (first review ~24h, then ~3d, ~7d, ~14d, lengthening with stability; lapses trigger relearning). These come out of FSRS naturally; for an SM-2 fallback they are explicit.

### 7.3 The due queue (what the learner sees each day)

```ts
function dueQueue(userId:ID, examContext:string, now:number, budget:number):ReviewItem[] {
  const due = srs.where({userId, examContext, dueAt: {'<=':now}, state:{'!=':'suspended'}});
  return due
    .sort(byPriority)        // overdue-most + lapsed + weak-topic first; interleave topics (§7.5)
    .slice(0, budget);       // respect the learner's daily time budget
}
```

### 7.4 Exam-deadline-aware scheduling  *(product differentiator)*

A working banker has a **fixed exam date**. Pure long-term SRS will schedule reviews *after* the exam — useless. So the scheduler is horizon-aware:

- `clampToExam(due, ctx)` never schedules a review past `examDate`. If FSRS wants a 40-day interval but the exam is in 20 days, the review is pulled in.
- As the exam approaches, the scheduler shifts modes:
  - **>8 weeks out → retention mode:** normal FSRS intervals; prioritize new coverage.
  - **2–8 weeks → consolidation mode:** compress intervals so every weak item is seen ≥2× before exam; raise weak-topic weighting.
  - **<2 weeks → coverage/cram mode:** prioritize unseen + lapsed items, breadth over depth, daily full-syllabus interleave.

This is a genuine edge over both incumbents (no SRS at all) and generic SRS apps (deadline-blind).

### 7.5 Interleaving & weak-topic weighting

Daily queues **mix topics** (one Accounting, one ESI, one Reasoning) to build discrimination and mirror the multi-section exam. Items in topics where the learner's recent accuracy is low get a priority multiplier; mock errors (§8) inject high-priority relearning items.

### 7.6 Difficulty calibration

Authored `difficulty` (1–5) seeds the model; as response data accrues, item difficulty is refined (per-item accuracy / latency, optionally a lightweight IRT pass server-side) and fed back into FSRS and into mock blueprint difficulty mixes.

---

## 8. Assessment / mock engine

Mocks are the **measurement layer** on top of the habit/SRS engine (study §11: don't try to out-volume Oliveboard/Adda247 — make mocks smart, not numerous).

**Assembly:** a `MockBlueprint` (§6) selects questions from the bank by `topicTags`, `count`, and `difficultyMix`, honoring `allowedTypes` per section. Supports **Full Mock**, **Sectional**, **Daily Quiz**, and **Adaptive Mock** (next item difficulty tracks running ability — reuses §7.6 calibration).

**Delivery:** enforces the exam's timing model (`sectionalTiming`, per-section `durationMin`, overall duration), renders composite sets (§4.4) as units, supports flag-for-review and navigation matching the real exam UI.

**Scoring:** auto types graded on submit (on-device for instant feedback, reconciled server-side); descriptive types → `pending` → assisted-rubric grading → result push. Applies the exam `MarkingRule` and `PassRule` (incl. JAIIB's two-path rule, sectional cutoffs, carry-forward). Produces sectional + overall scores, percentile vs. cohort (server), and a **topic-level weakness map**.

**Feedback loop (the differentiator):** every wrong/guessed mock answer becomes a **high-priority SRS relearning item**, and weak topics raise queue weighting. The mock doesn't just *report* weakness — it *reschedules* the fix.

```ts
function onMockGraded(userId:ID, result:MockResult) {
  for (const ans of result.answers)
    if (ans.correctness!=='correct')
      srs.upsertRelearning(userId, ans.questionId, /*priority*/ 'high');
  analytics.emit('mock_completed', summarize(result));
}
```

---

## 9. Offline-first storage & sync

**Local store (SQLite):** downloaded content packs (immutable, versioned), SRS state, an append-only **event log**, and a sync cursor. The device computes the due queue and grades auto-types **fully offline** (commute studying).

**Event sourcing:** learner actions are events — `lesson_viewed`, `card_reviewed`, `question_answered`, `mock_submitted`. Events are immutable and carry a client ULID + timestamp.

**Sync protocol:**
1. **Pull content:** client sends held pack versions; server returns deltas (new/updated lessons, questions, configs, assets). Packs are versioned & immutable — a content fix ships a new version, never mutates in place.
2. **Push events:** client uploads buffered events since cursor (idempotent by event id). Server appends, advances cursor.
3. **Reconcile SRS:** SRS state is a **projection** of events. Both client and server can project; to avoid drift, server projection is authoritative and returns updated `SrsState` rows. Conflicts (same item reviewed on two devices) resolve by event timestamp order (deterministic replay) — effectively conflict-free because state is derived, not directly written.
4. **Descriptive grading:** answers stored locally as `pending`; on sync, routed to the grading service; results pushed back and surfaced as notifications.

**Asset delivery:** images/animations/audio in object storage + CDN; referenced by id; prefetched per downloaded pack for offline use; lazy for the rest.

---

## 10. Data storage (core tables)

```
exams(id, code, name, body, config_id, version, status)
papers(id, exam_code, name, kind)
modules(id, paper_id, name, topic_tags[])
lessons(id, module_id, title, est_minutes, version)
cards(id, lesson_id, kind, blocks_json, srs_eligible)
questions(id, type, topic_tags[], difficulty, grading_mode,
          default_marks, default_neg, payload_json, stimulus_id, version, status)
stimuli(id, kind, content_json, asset_id, child_question_ids[])
assets(id, kind, url, alt, checksum)
exam_configs(id, exam_code, version, doc_json)          -- §6 document
content_pack_versions(exam_code, version, manifest_json) -- delta sync

users(id, ...)                 user_exam_enrollments(user_id, exam_code, exam_date, active)
learnable_items(id, kind, ref_id, probe_question_ids[], topic_tags[], exam_contexts[])
srs_state(user_id, item_id, exam_context, algo, stability, difficulty,
          due_at, last_reviewed_at, reps, lapses, state)     PK(user_id, item_id, exam_context)
events(id, user_id, kind, payload_json, client_ts, server_ts)  -- append-only
mock_attempts(id, user_id, blueprint_id, started_at, submitted_at, score_json, status)
answers(id, attempt_or_lesson_id, question_id, response_json, grade_json, correctness)
grading_jobs(id, answer_id, mode, status, rubric_scores_json, reviewer_id)  -- descriptive
```

Localized strings stored as JSON maps keyed by `LangCode` (§12.4). `payload_json` is the per-type union (§4) validated on write against the type's JSON Schema.

---

## 11. API surface (representative)

```
# Content & config (versioned, cacheable)
GET  /v1/exams                                   -> exam list + versions
GET  /v1/exams/{code}/pack?have={versions}       -> content-pack delta
GET  /v1/exams/{code}/config                      -> ExamConfig

# Learning loop
GET  /v1/users/me/queue?exam={code}&budget=20    -> due SRS items (server can also project)
POST /v1/users/me/events                          -> batch upload events (idempotent)
GET  /v1/users/me/progress?exam={code}            -> mastery map, streak, coverage

# Mocks
POST /v1/mocks                                    -> assemble from blueprint
POST /v1/mocks/{id}/submit                        -> grade auto; enqueue descriptive
GET  /v1/mocks/{id}/result                        -> sectional/overall, percentile, weakness map

# Descriptive grading
GET  /v1/grading/{answerId}                       -> status/result (assisted+review)
```

All idempotent writes keyed by client-generated ULIDs; auth via short-lived tokens.

---

## 12. Authoring (CMS), validation, versioning, localization

**12.1 Authoring.** SMEs author in a headless CMS: build lessons (cards), write questions by picking a **type** (form adapts to the payload schema), attach assets, set rubrics for descriptive items, tag topics. No deploys to publish content.

**12.2 Validation (gate to publish).** Each question is validated against its type's **JSON Schema** *and* type-specific rules: MCQ has exactly one correct option (for `mcq_single`); numeric has tolerance set; essay has a rubric; passage children reference a valid stimulus; every localized field present for declared `languages`. Invalid content can't reach `published`.

**12.3 Versioning.** Content is **immutable + versioned**. Edits create a new version; packs reference versions; in-flight learner attempts pin the version they started. This keeps offline clients consistent and makes syllabus updates (e.g. IIBF revisions) auditable.

**12.4 Localization.** Every learner-facing string is `Record<LangCode,string>`. Exam config declares `languages`; validation enforces completeness. Adding Hindi = supply translations + voiceover assets; engine, schema, and logic unchanged.

---

## 13. End-to-end worked examples (different formats, one engine)

**(a) JAIIB lesson probe — `mcq_single`, no negative marking**
```json
{ "id":"q_ppb_001","type":"mcq_single","topicTags":["ppb.kyc"],"difficulty":2,
  "gradingMode":"auto_exact","defaultMarks":1,"defaultNegativeMarks":0,
  "payload":{ "type":"mcq_single",
    "stem":{"en":"Which document is NOT a valid 'Officially Valid Document' for KYC?"},
    "options":[{"id":"a","content":{"en":"Passport"}},{"id":"b","content":{"en":"Voter ID"}},
               {"id":"c","content":{"en":"Club membership card"}},{"id":"d","content":{"en":"Driving licence"}}],
    "correctOptionId":"c" },
  "explanation":{"en":"OVDs are government-issued identity proofs; a club card is not."} }
```

**(b) IBPS Quant DI set — `Stimulus(chart)` + `passage_ref → numeric`, −0.25**
```json
{ "stimulus":{ "id":"st_di_07","kind":"chart","chartSpec":{ "...":"bar: bank deposits by year" },
    "childQuestionIds":["q_di_07_1","q_di_07_2"] },
  "questions":[
   { "id":"q_di_07_1","type":"passage_ref","topicTags":["quant.di"],"gradingMode":"auto_numeric",
     "defaultMarks":1,"defaultNegativeMarks":0.25,"stimulusId":"st_di_07",
     "payload":{ "type":"passage_ref","innerType":"numeric",
       "inner":{ "type":"numeric","stem":{"en":"% growth in deposits 2023→2024?"},
                 "answer":{"value":12.5,"unit":"%"},"tolerance":{"kind":"absolute","amount":0.1} } } }
  ] }
```

**(c) RBI Grade B Phase 2 — `essay`, assisted rubric grading**
```json
{ "id":"q_esi_essay_03","type":"essay","topicTags":["esi.inflation"],"difficulty":4,
  "gradingMode":"assisted_rubric","defaultMarks":25,"defaultNegativeMarks":0,
  "payload":{ "type":"essay",
    "prompt":{"en":"Discuss the trade-offs the RBI faces between inflation control and growth."},
    "wordLimit":{"min":250,"max":400},
    "rubric":[ {"id":"r1","label":"Conceptual accuracy","maxScore":10,"guidance":"Correct use of monetary policy tools"},
               {"id":"r2","label":"Structure & argument","maxScore":8,"guidance":"Clear thesis, balanced trade-offs"},
               {"id":"r3","label":"Examples/data","maxScore":7,"guidance":"Relevant Indian context"} ] } }
```

**(d) NABARD reasoning — `ordering`, partial credit**
```json
{ "id":"q_re_ord_12","type":"ordering","topicTags":["reasoning.sequence"],"gradingMode":"auto_exact",
  "defaultMarks":1,"defaultNegativeMarks":0,
  "payload":{ "type":"ordering","stem":{"en":"Arrange the loan-sanction steps in order."},
    "items":[{"id":"i1","content":{"en":"Appraisal"}},{"id":"i2","content":{"en":"Application"}},
             {"id":"i3","content":{"en":"Sanction"}},{"id":"i4","content":{"en":"Disbursement"}}],
    "correctOrder":["i2","i1","i3","i4"],"partialCredit":"kendall_tau" } }
```

All four are authored, validated, rendered, graded, scheduled into SRS, and assembled into mocks by the **same engine** — they differ only in payload + config.

---

## 14. Build order

1. **Content schema + Question-type envelope/union + JSON-Schema validation** (§3–4). The foundation; hardest to migrate later.
2. **Auto graders + marking/scoring from config** (§5–6) for the objective types. Enables JAIIB end-to-end.
3. **SRS state model + FSRS scheduler + exam-deadline-aware clamping** (§7). The retention moat.
4. **Offline store + event-sourced sync** (§9). Required before real-world pilots.
5. **Mock engine + mock→SRS feedback loop** (§8).
6. **Descriptive/assisted grading pipeline** (§5) — only when shipping RBI GB Phase 2 / NABARD descriptive.
7. **CMS authoring + versioning + localization** (§12) hardening as content volume grows.

Phasing aligns with the product roadmap (study §9): steps 1–5 cover JAIIB→CAIIB→IBPS-style objective exams; step 6 unlocks the descriptive regulator exams.

---

## 15. Build decisions (resolved)

These were the open calls; each is now resolved for the IIBF / working-professional / offline-first / calm-UI context. The one decision that still depends on a fact only you hold (existing team skills) is flagged.

**1. SRS algorithm → FSRS, with default parameters at launch.**
FSRS gives a materially better retention-vs-effort trade-off than SM-2 and is the modern standard (it's what Anki now ships). Use the **published default weights** at launch — per-user parameter optimization needs ~1,000+ reviews per learner, so personalize *later* once data exists. Keep it behind the `Scheduler` interface (§7.2) so SM-2 remains a fallback and parameter optimization can be added without touching callers. The algorithm core is ~200 lines and has ports across Python/Rust/JS/Dart; if no maintained Dart port fits, port the reference once and unit-test against published vectors.

**2. Descriptive grading → deferred (out of scope).**
IIBF exams are objective MCQ, so the assisted-rubric pipeline (§5) stays defined in the engine but is **not built now**. Revisit only if the platform later targets a descriptive exam (e.g. RBI Grade B Phase 2).

**3. Objective-mock grading location → hybrid by context.**
- *Lessons & practice mocks:* grade **on-device** (ship the answer key in the content pack) → instant feedback, fully offline. This is the common path and the calm/fast UX the product promises.
- *Competitive / cohort mocks* (where rank or integrity matters): **server-authoritative** — withhold the key from the pack, grade on submit. Prevents key-extraction and keeps leaderboards honest.
Both reconcile through the event log (§9); on-device results are advisory, server is system-of-record. Complexity is low because IIBF scoring is trivial (1 mark/MCQ, no negative marking).

**4. Cross-platform framework → Flutter (confirmed).**
Chosen for the product's **custom question renderers** (caselets, charts, formulas), **pixel-consistent calm design system**, smooth micro-animations, and **offline SQLite** — all of which favor Flutter's single rendering engine and mature offline tooling. Suggested stack: **drift/sqflite** (local store + SRS state), a predictable state layer (**Riverpod** or **Bloc**), and a **shared design-token system** for the calm light/dark theme. The **B2B manager dashboard** remains a separate web surface (React/Next.js) — it does not share the mobile stack.

**5. Partial-credit policy → off for scoring; partial credit is a practice-feedback feature only.**
Every IIBF exam is single-best-answer MCQ with no negative marking, so official/mock scoring is **all-or-nothing** (`allowPartialDefault: false` in every exam config). Retain the per-type partial-credit logic (§5) purely for *pedagogical feedback* in practice mode (e.g. "you matched 2 of 3 pairs") — it never affects a mock score.

**6. Mock breadth → author in-house (SME-led, AI-assisted variants); do not license.**
There is no clean licensable IIBF MCQ bank, and out-voluming Learning Sessions/Oliveboard is the wrong game (study §13). Build a focused, syllabus-mapped bank authored by SMEs; use AI to generate **question variants from SME-approved seeds** (with mandatory SME review) to gain breadth without sacrificing accuracy. Mocks are the **measurement layer** on the SRS/habit engine, not a volume play.

**Net effect on the build:** decisions 2, 3, 5 *reduce* scope (no descriptive pipeline, trivial scoring, simple grading split); decisions 1 and 4 lock the two foundational technology choices; decision 6 sets the content strategy. None blocks starting P0 (spec §14).
