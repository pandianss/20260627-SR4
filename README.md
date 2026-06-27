# IIBF Professional Certifications micro-learning platform

A calm, minimal micro-learning app for working bankers preparing for **IIBF
professional certifications** — JAIIB, CAIIB, and the specialised certificates
(International Banking, Risk Management, Credit, Treasury, AML/KYC, …). One
reusable engine powers the whole exam family via per-exam content packs.

The bet: incumbents (Learning Sessions, Oliveboard, EduTap, Ambitious Baba)
sell *content volume* — 150+ hours of video, fat PDFs, giant mock banks. We sell
**retention and calm**: 5-minute lessons, spaced repetition, and a deliberately
low-strain interface for tired professionals studying at night.

## Repository layout

```
packages/domain/      Pure-Dart shared model — the engine's foundation (epic E1)
  lib/src/
    localized.dart       Multilingual strings (E1.4)
    content.dart         Exam -> Paper -> Module -> Lesson -> Card, Stimulus, Asset (E1.1)
    question.dart        Polymorphic question-type union (E1.2)
    exam_config.dart     Declarative per-exam config (papers, marking, pass rule)
    validation.dart      Publish-gate validator (E1.3)
packages/grading/     Deterministic grading & scoring engine (epic E2)
  lib/src/
    response.dart        Learner answer model (per question type)
    grader.dart          Auto-graders + numeric tolerance (E2.1/E2.2)
    marking.dart         Config-driven marking application (E2.3)
    scoring.dart         Pass-rule evaluation (e.g. JAIIB two-path)
content/exams/        Exam-config documents (e.g. jaiib.config.json — E2.4)
schemas/              Language-neutral JSON Schema contracts (for the backend)
docs/:
  banking-microlearning-study.md   Sourced strategy study
  technical-spec.md                Engine spec (questions, SRS, sync, decisions)
  design-system.md                 Calm design tokens (Flutter-ready)
  jaiib-content-pack-example.md     Worked JAIIB lesson + authoring checklist
  caiib-content-pack-example.md     Harder CAIIB lesson (formulas, multi-step)
  p0-build-backlog.md              Engineering epics & tickets
  deep-research-report.md          Background research
  PRIVACY.md                       Privacy policy draft
```

## Tech decisions (see `docs/technical-spec.md` §15)

- **Flutter** mobile (offline-first; drift/sqflite; Riverpod or Bloc).
- **FSRS** spaced-repetition scheduler (default weights at launch, swappable).
- **Objective MCQ only** (IIBF format) — no descriptive grading in scope.
- Shared **pure-Dart `domain`** package used by app and backend.

## Getting started

```bash
cd packages/domain
dart pub get
dart test          # 16 tests, all green
```

## Status

| Epic | Scope | Status |
|------|-------|--------|
| **E1** | Content schema + question-type system + validation | ✅ implemented + tested |
| **E2** | Grading & scoring engine (graders, marking, pass rule) | ✅ implemented + tested |
| E3 | FSRS spaced-repetition engine | next |
| E4 | Offline store & sync | planned |
| E5–E10 | App shell, renderers, mocks, content, release | planned (see `docs/p0-build-backlog.md`) |

33 tests passing (`dart test` in `packages/domain` and `packages/grading`).
