# CAIIB raw content + ingestion

Upstream authoring data for **CAIIB** (Advanced Bank Management, Bank Financial
Management, Advanced Business & Financial Management, Banking Regulations &
Business Laws + electives: Risk, IT, HR, Rural, Central Banking).

This is the **durable source of truth** (it used to live under `temp/`, which is
disposable). Do not delete.

## Files
| File | Contents |
|---|---|
| `contentGraph.js` | `SUBJECTS`, `ELECTIVES`, `MODULES`, `TOPICS`, `FORMULAS`, `RBI_CIRCULARS`, `MODULE_SUMMARIES` — the syllabus graph |
| `microLessons.js` | `MICRO_LESSONS` — 308 micro-lessons (concept / pillars / scenario / quiz steps) |
| `questionBank.js` | `QUESTION_BANK` — MCQ bank (merges the supplement at load) |
| `questionBankSupplement.js` | `QUESTION_BANK_SUPPLEMENT` — easy-tier MCQs |
| `ingestedCirculars.json` | RBI circulars reference data (not yet mapped into the pack) |
| `package.json` | marks this dir as an ES module so the transform can `import` the `.js` files |

## Pipeline
```
content/raw/caiib/*.js                      (this dir — raw authoring data)
        │  node tools/ingest_caiib.mjs
        ▼
packages/app/assets/content_pack_caiib.json (engine-schema content pack, bundled by the app)
        │  dart run packages/domain/bin/validate_pack.dart <pack>
        ▼
0 errors  →  ready to ship
```

Regenerate after editing the raw data:
```bash
node tools/ingest_caiib.mjs
dart run packages/domain/bin/validate_pack.dart packages/app/assets/content_pack_caiib.json
```

## Mapping (raw → engine schema)
- `SUBJECTS` + `ELECTIVES` → **papers** (4 compulsory + 5 elective), `exam = CAIIB`
- `MODULES` → **modules** (`topicTags` from `TOPICS`)
- `MICRO_LESSONS` → **lessons**: `concept`/`pillars` → concept cards, `scenario` → example card, `quiz` → a probe `mcq_single` question
- `QUESTION_BANK` (+ supplement) → standalone **questions** (`mcq_single`)
- `FORMULAS`, `RBI_CIRCULARS`, `MODULE_SUMMARIES` are preserved here but not yet
  mapped into the pack (no schema slot today).
