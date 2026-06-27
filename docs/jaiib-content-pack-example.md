# JAIIB Content-Pack Template — a fully worked lesson

*Companion to [technical-spec.md](technical-spec.md) (§3 content model, §4 question types) and the calm/micro design in [banking-microlearning-study.md](banking-microlearning-study.md) §5. This is the pattern SMEs author against — one worked lesson, end to end, in the engine's schema. It is exactly the content behind the prototype screens (Cash Reserve Ratio).*

---

## 1. Where this lesson sits

```
Exam:   JAIIB
Paper:  Principles & Practices of Banking   (paperCode: PPB)
Module: Banking regulation & the RBI         (topicTags: ["ppb.regulation","ppb.reserves"])
Lesson: Cash Reserve Ratio & SLR             (~5 min · 5 cards · 1 caselet · 2 standalone MCQs)
```

A lesson is the unit a learner finishes in one sitting. Target **≤5 minutes**: 4–6 cards, then 3–4 retrieval items (one of them a caselet). Card:retrieval ≈ 5:1 (spec §1, study §6).

---

## 2. The lesson object

```json
{
  "id": "les_ppb_crr_slr",
  "moduleId": "mod_ppb_regulation",
  "title": { "en": "Cash reserve ratio & SLR", "hi": "नकद आरक्षित अनुपात और एसएलआर" },
  "estMinutes": 5,
  "version": 1,
  "cards": [ "card_intro", "card_crr", "card_slr", "card_diff", "card_recap" ],
  "probeQuestionIds": [ "q_crr_holder", "cs_crr_caselet", "q_slr_assets" ]
}
```

*(Cards listed by id for brevity; the full card objects follow. `probeQuestionIds` reference the shared `QuestionBank` — the same questions can also appear in mocks.)*

---

## 3. The cards (teaching content)

Each concept card carries **one idea**, visual-first, minimal text. `srsEligible: true` marks the cards whose knowledge enters spaced repetition (§5).

```json
[
  {
    "id": "card_intro", "kind": "intro", "srsEligible": false,
    "blocks": [
      { "kind": "text", "md": { "en": "Banks can't lend out every rupee you deposit. By law they must set some aside. Two rules control how much." } }
    ]
  },
  {
    "id": "card_crr", "kind": "concept", "srsEligible": true,
    "blocks": [
      { "kind": "text", "md": { "en": "**Cash Reserve Ratio (CRR)** — the share of deposits a bank must keep as cash with the RBI. It earns no interest and cannot be lent out." } },
      { "kind": "chart", "spec": { "type": "bar_segment", "total": "Total deposits", "segment": { "label": "CRR 4.5%", "value": 4.5 } } }
    ]
  },
  {
    "id": "card_slr", "kind": "concept", "srsEligible": true,
    "blocks": [
      { "kind": "text", "md": { "en": "**Statutory Liquidity Ratio (SLR)** — the share of deposits a bank must hold in safe liquid assets (cash, gold, government securities) — kept *with the bank itself*, not the RBI." } },
      { "kind": "image", "assetId": "img_slr_assets", "alt": { "en": "Icons: cash, gold bar, government bond" } }
    ]
  },
  {
    "id": "card_diff", "kind": "example", "srsEligible": true,
    "blocks": [
      { "kind": "text", "md": { "en": "Quick contrast: **CRR** is cash, held **with the RBI**, no interest. **SLR** is liquid assets, held **by the bank**, can earn returns (e.g. G-secs)." } }
    ]
  },
  {
    "id": "card_recap", "kind": "recap", "srsEligible": false,
    "blocks": [
      { "kind": "text", "md": { "en": "CRR → cash with RBI. SLR → liquid assets with the bank. Both are set by the RBI to keep banks safe and to manage liquidity." } }
    ]
  }
]
```

**Note on `chart` blocks:** the renderer draws these client-side from a small spec (like the bar in the prototype's lesson screen) — SMEs supply data, not images, so charts stay crisp, localizable, and theme-aware (dark/soft-white) for free.

---

## 4. The retrieval items

### 4a. Standalone MCQ — `mcq_single` (no negative marking)

```json
{
  "id": "q_crr_holder", "version": 1,
  "topicTags": ["ppb.reserves", "ppb.crr"],
  "difficulty": 1,
  "gradingMode": "auto_exact",
  "defaultMarks": 1, "defaultNegativeMarks": 0,
  "payload": {
    "type": "mcq_single",
    "stem": { "en": "Where does a bank keep its CRR balance?" },
    "options": [
      { "id": "a", "content": { "en": "As cash in its own vault" } },
      { "id": "b", "content": { "en": "With the Reserve Bank of India" } },
      { "id": "c", "content": { "en": "In government securities" } },
      { "id": "d", "content": { "en": "With its sponsor bank" } }
    ],
    "correctOptionId": "b"
  },
  "explanation": { "en": "CRR is a cash balance maintained with the RBI; SLR (not CRR) may be held in G-secs." },
  "sourceRef": "RBI Act / Banking Regulation Act — reserve requirements"
}
```

### 4b. Caselet — `Stimulus{caselet}` + `passage_ref → numeric` (the signature IIBF format, and the prototype's question)

```json
{
  "stimulus": {
    "id": "cs_crr_caselet", "kind": "caselet",
    "content": { "en": "A bank holds ₹100 cr in deposits. The CRR is 4.5% and the SLR is 18%." },
    "childQuestionIds": ["cs_crr_q1", "cs_crr_q2"]
  },
  "questions": [
    {
      "id": "cs_crr_q1", "version": 1,
      "topicTags": ["ppb.crr"], "difficulty": 2,
      "gradingMode": "auto_numeric",
      "defaultMarks": 1, "defaultNegativeMarks": 0,
      "stimulusId": "cs_crr_caselet",
      "payload": {
        "type": "passage_ref", "innerType": "numeric",
        "inner": {
          "type": "numeric",
          "stem": { "en": "How much must it keep with the RBI as CRR?" },
          "answer": { "value": 4.5, "unit": "₹ cr" },
          "tolerance": { "kind": "absolute", "amount": 0.01 }
        }
      },
      "explanation": { "en": "4.5% of ₹100 cr = ₹4.5 cr." }
    },
    {
      "id": "cs_crr_q2", "version": 1,
      "topicTags": ["ppb.slr"], "difficulty": 2,
      "gradingMode": "auto_numeric",
      "defaultMarks": 1, "defaultNegativeMarks": 0,
      "stimulusId": "cs_crr_caselet",
      "payload": {
        "type": "passage_ref", "innerType": "numeric",
        "inner": {
          "type": "numeric",
          "stem": { "en": "How much must it hold as SLR?" },
          "answer": { "value": 18, "unit": "₹ cr" },
          "tolerance": { "kind": "absolute", "amount": 0.01 }
        }
      },
      "explanation": { "en": "18% of ₹100 cr = ₹18 cr, held by the bank in liquid assets." }
    }
  ]
}
```

*(The prototype showed this caselet as an MCQ for tap-friendliness; the engine supports either `numeric` entry or an `mcq_single` wrapper via `innerType` — the renderer picks the input. Author whichever fits the screen; the data is the same caselet.)*

### 4c. Second standalone MCQ — reinforces SLR

```json
{
  "id": "q_slr_assets", "version": 1,
  "topicTags": ["ppb.slr"], "difficulty": 2,
  "gradingMode": "auto_exact",
  "defaultMarks": 1, "defaultNegativeMarks": 0,
  "payload": {
    "type": "mcq_single",
    "stem": { "en": "Which of these can count towards a bank's SLR?" },
    "options": [
      { "id": "a", "content": { "en": "Government securities" } },
      { "id": "b", "content": { "en": "Loans to retail customers" } },
      { "id": "c", "content": { "en": "Its CRR balance with the RBI" } },
      { "id": "d", "content": { "en": "Fixed deposits placed with other banks" } }
    ],
    "correctOptionId": "a"
  },
  "explanation": { "en": "SLR is held in liquid assets such as cash, gold, and approved government securities." }
}
```

---

## 5. How this lesson enters spaced repetition

After the learner finishes the lesson, the three `srsEligible` cards become `LearnableItem`s (spec §7.1), each probed by a question so recall is *tested*, not just re-read:

| LearnableItem (card) | Probed by | First review |
|---|---|---|
| `card_crr` (CRR definition) | `q_crr_holder`, `cs_crr_q1` | ~24h later |
| `card_slr` (SLR definition) | `q_slr_assets`, `cs_crr_q2` | ~24h later |
| `card_diff` (CRR vs SLR) | rotates between the above | ~24h later |

The FSRS scheduler then spaces each item (≈1d → 3d → 7d → 14d, weak items sooner), clamped to the learner's JAIIB exam date (spec §7.4). A wrong answer in any mock re-injects the item as high-priority relearning (spec §8).

---

## 6. SME authoring checklist (the calm/micro rules)

Every lesson must pass this before `published` (enforced by validation, spec §12.2):

**Structure**
- [ ] 4–6 cards; **one idea per card**; intro + recap bookend the concepts.
- [ ] ≥3 retrieval items, including **one caselet** (IIBF's signature format).
- [ ] Estimated time ≤ 5 minutes.

**Calm / low-strain (the design pillar)**
- [ ] Concept card body ≤ ~30 words. If it needs more, split into two cards.
- [ ] **Visual-first**: each concept card has a chart, image, or formula block — not a wall of text.
- [ ] No card requires scrolling on a phone screen.
- [ ] Plain language; expand abbreviations on first use.

**Correctness & format**
- [ ] Single-best-answer MCQs; exactly one `correctOptionId`. `defaultNegativeMarks: 0` (IIBF rule).
- [ ] Numeric items have `answer.unit` and a `tolerance`.
- [ ] Every question has a one-line `explanation` (shown after answering — this *is* the teaching moment).
- [ ] `sourceRef` cites the syllabus/authority for high-stakes facts.

**Localization**
- [ ] All learner-facing strings present for every declared language (start: `en`, `hi`).
- [ ] Charts use data specs (not text-baked images) so they localize automatically.

---

## 7. How it maps to the screens

| Prototype screen | Content-pack source |
|---|---|
| Home — "Principles of banking, 62%" | module progress over its lessons; this lesson is one node |
| Lesson concept card — "Cash reserve ratio" + bar | `card_crr` (text block + `chart` block) |
| Caselet — "₹100 cr deposits, CRR 4.5%…" | `cs_crr_caselet` stimulus + `cs_crr_q1` |
| Spaced review — "What is the current CRR?" | `card_crr` resurfaced, probed by `q_crr_holder` |

One authored lesson → all four experiences, no extra work. Authoring the rest of JAIIB (and then CAIIB, Risk, International Banking…) is this same template, repeated and translated — which is exactly the "~90% content, ~10% config" thesis (spec §6.1).
