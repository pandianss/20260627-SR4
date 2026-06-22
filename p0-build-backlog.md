# P0 Build Backlog — engine + JAIIB pilot

*Turns the build order in [technical-spec.md](technical-spec.md) §14 into actionable epics and tickets. Scope is **P0 only**: the reusable engine + one JAIIB paper, shippable to a pilot cohort. Later exams (CAIIB, Risk, International Banking) are content + config on top of this — not in P0.*

---

## P0 definition of done

A JAIIB aspirant can:
1. Install the app (Flutter, dark·teal theme), sign in, pick JAIIB + set an exam date.
2. Study **one full JAIIB paper** (Principles & Practices of Banking) as ≤5-min calm micro-lessons — **fully offline**.
3. Get **spaced reviews** surfaced daily (FSRS), exam-date-aware.
4. Take a **practice mock** assembled from the question bank, graded instantly with a weakness map.
5. All progress **syncs** when back online.

And we can **measure D1/D7 retention** and lesson completion from analytics.

**Team assumption** (study §11): 1 PM, 1 UX, 2 Flutter devs, 1 backend dev, 1 content SME (banking), 1 QA. ~M1–4 / 8 two-week sprints.

**Sizing:** S ≈ ≤2 days · M ≈ 3–5 days · L ≈ 1–2 weeks. Owner roles: BE (backend), FE (Flutter), UX, SME, QA.

---

## E1 — Content schema & question-type system  *(foundation; build first)*

| ID | Ticket | Acceptance criteria | Size · Owner · Deps |
|---|---|---|---|
| E1.1 | Define content model | `Exam→Paper→Module→Lesson→Card` + `QuestionBank`, `Stimulus`, `Asset` as typed schema; serializes to JSON both sides (shared Dart + BE). | M · BE/FE · — |
| E1.2 | Question-type union (P0 subset) | `mcq_single`, `true_false`, `match_pairs`, `numeric`, `numeric_multistep`, `passage_ref`(caselet) implemented as discriminated payloads. | M · BE/FE · E1.1 |
| E1.3 | JSON-Schema validation + publish gate | Per-type validation (e.g. `mcq_single` has exactly one correct option; numeric has tolerance); invalid content cannot reach `published`. | M · BE · E1.2 |
| E1.4 | Localized-string type | All learner-facing strings are `{en, hi}`; validator enforces completeness for declared languages. | S · BE · E1.1 |

## E2 — Grading & scoring engine

| ID | Ticket | Acceptance criteria | Size · Owner · Deps |
|---|---|---|---|
| E2.1 | Auto graders (objective) | Graders for all P0 types; on-device (Dart) + server (authoritative) parity, unit-tested. | M · BE/FE · E1.2 |
| E2.2 | Numeric/tolerance + multi-step grading | Abs/relative/decimals tolerance; multi-step grades each step independently. | S · BE/FE · E2.1 |
| E2.3 | Exam-config marking application | Scoring reads marks/negative-marks from config (JAIIB = no negative marking, all-or-nothing). | S · BE · E2.1 |
| E2.4 | JAIIB exam-config doc | Declarative config: 1 paper, 100 MCQ, no negative marking, 50% + 45/aggregate pass rule. | S · BE · E1.3 |

## E3 — Spaced-repetition engine

| ID | Ticket | Acceptance criteria | Size · Owner · Deps |
|---|---|---|---|
| E3.1 | FSRS scheduler behind interface | `Scheduler` interface; FSRS default weights; unit-tested against reference vectors. | L · BE/FE · E1.1 |
| E3.2 | LearnableItem + SRS state model | `srsEligible` cards → items probed by questions; per-(user,item) state persisted. | M · BE/FE · E3.1 |
| E3.3 | Exam-deadline-aware clamping | Intervals never scheduled past exam date; retention→consolidation→cram modes (spec §7.4). | M · BE/FE · E3.1 |
| E3.4 | Daily due-queue + interleaving | Returns due items within a time budget, topic-interleaved, weak-topic weighted. | M · FE · E3.2 |

## E4 — Offline store & sync

| ID | Ticket | Acceptance criteria | Size · Owner · Deps |
|---|---|---|---|
| E4.1 | Local store (drift/sqflite) | Content packs + SRS state + event log persisted; app fully usable offline. | M · FE · E1.1 |
| E4.2 | Event-sourced action log | `lesson_viewed`/`question_answered`/`mock_submitted` appended with client ULIDs. | S · FE · E4.1 |
| E4.3 | Content-pack delta pull | Client sends held versions; server returns deltas; packs immutable + versioned. | M · BE/FE · E1.1 |
| E4.4 | Event push + SRS reconcile | Batched idempotent upload; server projection authoritative; deterministic replay (no conflicts). | M · BE/FE · E4.2, E3.2 |

## E5 — App shell & calm design system

| ID | Ticket | Acceptance criteria | Size · Owner · Deps |
|---|---|---|---|
| E5.1 | Flutter design tokens | `AppTokens` ThemeExtension (dark·teal default) per [design-system.md](design-system.md); light theme stubbed. | M · FE/UX · — |
| E5.2 | Core components | Button, card, option chip, pill, progress ring, rating buttons — token-driven, 44px targets. | M · FE/UX · E5.1 |
| E5.3 | Navigation + home screen | "Today's 5 minutes" one-action home; module progress ring; gentle weekly-goal streak. | M · FE/UX · E5.2 |
| E5.4 | Onboarding | Sign-in, pick JAIIB, set exam date; ≤4 calm screens. | S · FE/UX · E5.3 |

## E6 — Learning surfaces (renderers)

| ID | Ticket | Acceptance criteria | Size · Owner · Deps |
|---|---|---|---|
| E6.1 | Lesson player | Swipeable cards; `text`/`image`/`chart`/`formula` blocks render in calm theme; ≤5-min flow. | L · FE · E5.2, E1.1 |
| E6.2 | Caselet renderer | Stimulus shown once with child questions one-at-a-time; matches prototype. | M · FE · E6.1, E1.2 |
| E6.3 | Question inputs + feedback | MCQ/numeric/multi-step inputs; instant grade + gentle correction + `explanation`. | M · FE · E2.1, E6.1 |
| E6.4 | Review (SRS) surface | Daily due queue UI; recall card + Again/Good/Easy → FSRS update. | M · FE · E3.4, E6.3 |

## E7 — Mock engine

| ID | Ticket | Acceptance criteria | Size · Owner · Deps |
|---|---|---|---|
| E7.1 | Blueprint assembly | Assemble practice mock from bank by topic/difficulty per blueprint. | M · BE/FE · E1.2, E2.4 |
| E7.2 | Mock player + scoring | Timed delivery, JAIIB scoring/pass rule, sectional+overall result. | M · FE · E7.1, E2.3 |
| E7.3 | Mock → SRS feedback loop | Wrong/guessed answers injected as high-priority relearning items. | S · FE · E7.2, E3.2 |
| E7.4 | Weakness map | Topic-level accuracy summary after a mock. | S · FE · E7.2 |

## E8 — JAIIB content pack (one paper)

| ID | Ticket | Acceptance criteria | Size · Owner · Deps |
|---|---|---|---|
| E8.1 | Authoring pipeline (lightweight CMS) | SMEs author lessons/questions against the schema + validation; export a content pack. | L · BE/SME · E1.3 |
| E8.2 | Author PPB paper | Principles & Practices of Banking → modules/lessons/caselets/MCQs per the [JAIIB template](jaiib-content-pack-example.md), EN. | L · SME · E8.1 |
| E8.3 | SME review workflow | draft → review → published; second-reviewer sign-off on correctness. | M · BE/SME · E8.1 |
| E8.4 | Hindi pass (stretch) | PPB strings + key assets translated; validator green for `hi`. | M · SME · E8.2 |

## E9 — Plumbing: auth, analytics, notifications

| ID | Ticket | Acceptance criteria | Size · Owner · Deps |
|---|---|---|---|
| E9.1 | Auth (token-based) | Secure sign-in; tokens; account basics. | M · BE · — |
| E9.2 | Analytics events | DAU/MAU, D1/D7 retention, lesson completion, mock score instrumented + dashboard. | M · BE · E4.2 |
| E9.3 | One daily SRS notification | Single gentle nudge tied to due reviews ("5 cards due — 3 min"); user-configurable time; off-switch. | S · FE/BE · E3.4 |

## E10 — Pilot hardening & release

| ID | Ticket | Acceptance criteria | Size · Owner · Deps |
|---|---|---|---|
| E10.1 | Accessibility pass | Contrast, text-scaling, audio narration for PPB, screen-reader labels. | M · FE/QA · E6.* |
| E10.2 | QA: offline/sync/grading | Test matrix for offline study, conflict-free sync, grader correctness. | L · QA · E4.*, E2.* |
| E10.3 | Store packaging + crash/telemetry | Signed builds (iOS/Android), crash reporting, basic monitoring. | M · FE · all |
| E10.4 | Pilot rollout | Cohort onboarded; retention dashboard live; feedback channel. | S · PM · E9.2 |

---

## Suggested sequence (8 sprints)

| Sprint | Focus |
|---|---|
| 1–2 | E1 (schema/types/validation), E5.1–5.2 (tokens/components), E9.1 (auth) — foundations in parallel. |
| 3–4 | E2 (grading/config), E3.1–3.2 (FSRS), E4.1–4.2 (local store/events), E6.1 (lesson player), E8.1 (authoring pipeline). |
| 5–6 | E3.3–3.4 + E6.2–6.4 (caselet, inputs, review), E4.3–4.4 (sync), E8.2 (author PPB), E9.2 (analytics). |
| 7 | E7 (mock engine + feedback loop), E9.3 (notification), E8.3 (review workflow). |
| 8 | E10 (accessibility, QA, packaging, pilot rollout). E8.4 (Hindi) if capacity. |

## Explicitly **not** in P0 (the cut-line)

- Descriptive/assisted grading (no descriptive in IIBF scope — spec §15.2).
- CAIIB / Risk / International Banking content (post-P0, content+config only).
- B2B manager dashboard (separate web app, P3).
- Leaderboards / social, light theme as default, regional languages beyond Hindi.
- Adaptive mock difficulty, IRT calibration (post-P0 enhancement).

Keeping these out is the discipline that makes a calm, focused P0 shippable.
