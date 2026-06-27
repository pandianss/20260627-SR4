# CAIIB Content-Pack Template — stress-testing the harder formats

*Second worked lesson (companion to [jaiib-content-pack-example.md](jaiib-content-pack-example.md)). JAIIB exercised text + MCQ + a numeric caselet. CAIIB — especially the **Risk Management** elective and **Bank Financial Management** — needs **formulas, multi-step calculations, and tolerance-based numeric grading**. This lesson proves the same schema (technical-spec §4) handles them with no engine change.*

---

## 1. Where this lesson sits

```
Exam:   CAIIB
Paper:  Elective — Risk Management        (paperCode: ELECTIVE / RISK_MGMT)
Module: Credit risk                        (topicTags: ["risk.credit","basel.el"])
Lesson: Expected loss (PD × LGD × EAD)     (~6 min · 5 cards · 1 multi-step · 1 caselet · 1 MCQ)
```

> **Reuse note:** this pack is tagged `risk.credit` / `basel.el`, not bound to CAIIB. The *same* lesson serves the **standalone IIBF Risk certificate** and overlaps the **International Banking** syllabus (Basel exposure concepts) — author once, ship to three exams (study §9, spec §6.1).

---

## 2. The lesson object

```json
{
  "id": "les_risk_expected_loss",
  "moduleId": "mod_risk_credit",
  "title": { "en": "Expected loss: PD × LGD × EAD", "hi": "अपेक्षित हानि: PD × LGD × EAD" },
  "estMinutes": 6,
  "version": 1,
  "cards": [ "card_el_intro", "card_el_formula", "card_el_inputs", "card_el_worked", "card_el_recap" ],
  "probeQuestionIds": [ "q_lgd_concept", "ms_el_calc", "cs_el_caselet" ]
}
```

---

## 3. The cards — now with `formula` blocks

```json
[
  {
    "id": "card_el_intro", "kind": "intro", "srsEligible": false,
    "blocks": [
      { "kind": "text", "md": { "en": "Some borrowers default. Banks don't guess the cost — they estimate it. The standard measure is **expected loss (EL)**." } }
    ]
  },
  {
    "id": "card_el_formula", "kind": "concept", "srsEligible": true,
    "blocks": [
      { "kind": "text", "md": { "en": "Expected loss combines three drivers:" } },
      { "kind": "formula", "latex": "EL = PD \\times LGD \\times EAD" }
    ]
  },
  {
    "id": "card_el_inputs", "kind": "concept", "srsEligible": true,
    "blocks": [
      { "kind": "text", "md": { "en": "**PD** — probability of default (how likely). **LGD** — loss given default = 1 − recovery rate (how much is lost). **EAD** — exposure at default (how much is owed)." } }
    ]
  },
  {
    "id": "card_el_worked", "kind": "example", "srsEligible": true,
    "blocks": [
      { "kind": "text", "md": { "en": "EAD ₹500 cr, PD 2%, LGD 45%:" } },
      { "kind": "formula", "latex": "EL = 0.02 \\times 0.45 \\times 500 = ₹4.5\\ \\text{cr}" }
    ]
  },
  {
    "id": "card_el_recap", "kind": "recap", "srsEligible": false,
    "blocks": [
      { "kind": "text", "md": { "en": "EL = PD × LGD × EAD. Raise any one input and expected loss rises proportionally. This feeds loan pricing and capital." } }
    ]
  }
]
```

**Renderer note:** `formula` blocks render via a math engine (e.g. KaTeX) themed to the calm dark/soft-white tokens — SMEs write LaTeX, not images, so formulas stay crisp and localizable.

---

## 4. The retrieval items — the harder formats

### 4a. Concept MCQ — `mcq_single`

```json
{
  "id": "q_lgd_concept", "version": 1,
  "topicTags": ["risk.credit","basel.lgd"], "difficulty": 2,
  "gradingMode": "auto_exact", "defaultMarks": 1, "defaultNegativeMarks": 0,
  "payload": {
    "type": "mcq_single",
    "stem": { "en": "If a bank expects to recover 60% of a defaulted loan, what is the LGD?" },
    "options": [
      { "id": "a", "content": { "en": "60%" } },
      { "id": "b", "content": { "en": "40%" } },
      { "id": "c", "content": { "en": "100%" } },
      { "id": "d", "content": { "en": "It cannot be determined" } }
    ],
    "correctOptionId": "b"
  },
  "explanation": { "en": "LGD = 1 − recovery rate = 1 − 0.60 = 40%." }
}
```

### 4b. Multi-step calculation — `numeric_multistep` (the format JAIIB never used)

Guides the learner through a layered calc, grading each step with tolerance — Brilliant-style "do it", not just recognise it.

```json
{
  "id": "ms_el_calc", "version": 1,
  "topicTags": ["risk.credit","basel.el"], "difficulty": 3,
  "gradingMode": "auto_numeric", "defaultMarks": 2, "defaultNegativeMarks": 0,
  "payload": {
    "type": "numeric_multistep",
    "stem": { "en": "A loan has EAD ₹500 cr, PD 2%, LGD 45%. Work out the expected loss." },
    "steps": [
      {
        "id": "s1",
        "prompt": { "en": "First, PD × EAD = ?" },
        "answer": 10, "tolerance": 0.01,
        "hint": { "en": "2% of ₹500 cr." }
      },
      {
        "id": "s2",
        "prompt": { "en": "Now apply LGD of 45%. Expected loss = ?" },
        "answer": 4.5, "tolerance": 0.01,
        "hint": { "en": "45% of the previous answer." }
      }
    ]
  },
  "explanation": { "en": "PD × EAD = ₹10 cr; × LGD 45% = ₹4.5 cr expected loss." }
}
```

### 4c. Caselet — `Stimulus{caselet}` + `passage_ref → numeric` (numeric children with sensitivity)

```json
{
  "stimulus": {
    "id": "cs_el_caselet", "kind": "caselet",
    "content": { "en": "A corporate loan has EAD ₹800 cr, PD 1.5%, and LGD 40%." },
    "childQuestionIds": ["cs_el_q1", "cs_el_q2"]
  },
  "questions": [
    {
      "id": "cs_el_q1", "version": 1, "topicTags": ["basel.el"], "difficulty": 3,
      "gradingMode": "auto_numeric", "defaultMarks": 1, "defaultNegativeMarks": 0,
      "stimulusId": "cs_el_caselet",
      "payload": { "type": "passage_ref", "innerType": "numeric",
        "inner": { "type": "numeric",
          "stem": { "en": "What is the expected loss?" },
          "answer": { "value": 4.8, "unit": "₹ cr" },
          "tolerance": { "kind": "absolute", "amount": 0.01 } } },
      "explanation": { "en": "0.015 × 0.40 × 800 = ₹4.8 cr." }
    },
    {
      "id": "cs_el_q2", "version": 1, "topicTags": ["basel.el"], "difficulty": 4,
      "gradingMode": "auto_numeric", "defaultMarks": 1, "defaultNegativeMarks": 0,
      "stimulusId": "cs_el_caselet",
      "payload": { "type": "passage_ref", "innerType": "numeric",
        "inner": { "type": "numeric",
          "stem": { "en": "If weaker collateral pushes LGD to 60%, what is the new expected loss?" },
          "answer": { "value": 7.2, "unit": "₹ cr" },
          "tolerance": { "kind": "absolute", "amount": 0.01 } } },
      "explanation": { "en": "0.015 × 0.60 × 800 = ₹7.2 cr — higher LGD lifts EL proportionally." }
    }
  ]
}
```

---

## 5. What this stress-test proves

| Capability | JAIIB lesson | This CAIIB lesson |
|---|---|---|
| Text + MCQ | ✅ | ✅ |
| `formula` (LaTeX) cards | — | ✅ EL = PD × LGD × EAD |
| `numeric` with tolerance | ✅ (simple %) | ✅ (multi-input) |
| **`numeric_multistep`** | — | ✅ guided 2-step calc |
| Caselet with **sensitivity** (change an input, re-compute) | — | ✅ LGD 40% → 60% |
| Difficulty range | 1–2 | 2–4 |

**Conclusion:** the schema, graders (`auto_numeric`), SRS, and renderer absorb the harder CAIIB/Risk formats **with zero engine change** — only new payload types (`formula`, `numeric_multistep`) that were already defined in spec §4. The authoring checklist (JAIIB §6) holds, with two additions for numeric topics:

- [ ] Every numeric item has `tolerance` (avoid penalising rounding).
- [ ] Multi-step items grade **each step** and offer a `hint`, so a tired learner is guided, not stuck.
- [ ] Formulas are LaTeX `formula` blocks, never screenshots.
