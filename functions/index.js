const { onRequest } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { defineSecret } = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const crypto = require("crypto");
const Anthropic = require("@anthropic-ai/sdk");

admin.initializeApp();
const db = admin.firestore();

// Anthropic API key — set once with:
//   firebase functions:secrets:set ANTHROPIC_API_KEY
const ANTHROPIC_API_KEY = defineSecret("ANTHROPIC_API_KEY");

// Predefined seed data from packages/app/assets/content_pack_updates.json
const SEED_UPDATES = [
  {
    "id": "rbi-2026-06-25-digital-lending",
    "regulator": "RBI",
    "title": "Revised Digital Lending Guidelines issued",
    "summary": "Updated rules on default loss guarantee (DLG) caps and disclosures for Lending Service Providers. Relevant to digital-lending and fintech topics.",
    "category": "Digital Lending",
    "priority": "important",
    "publishedAt": "2026-06-25",
    "sourceUrl": "https://www.rbi.org.in/",
    "affectsTopics": ["digital-lending", "fintech"]
  },
  {
    "id": "iibf-2026-06-22-caiib-window",
    "regulator": "IIBF",
    "title": "CAIIB November 2026 registration window opens",
    "summary": "Online registration for the CAIIB November 2026 attempt is now open. Check eligibility and exam-centre options before the last date.",
    "category": "Exam notice",
    "priority": "critical",
    "publishedAt": "2026-06-22",
    "sourceUrl": "https://www.iibf.org.in/",
    "affectsTopics": ["exam-schedule"]
  },
  {
    "id": "rbi-2026-06-20-mpc-repo",
    "regulator": "RBI",
    "title": "MPC keeps the policy repo rate unchanged at 6.50%",
    "summary": "The Monetary Policy Committee retained the repo rate at 6.50% and continued its stance on withdrawal of accommodation. Relevant to monetary-policy and interest-rate questions.",
    "category": "Monetary Policy",
    "priority": "important",
    "publishedAt": "2026-06-20",
    "sourceUrl": "https://www.rbi.org.in/Scripts/BS_PressReleaseDisplay.aspx",
    "affectsTopics": ["monetary-policy", "interest-rates"]
  },
  {
    "id": "sebi-2026-06-18-mf-disclosure",
    "regulator": "SEBI",
    "title": "Tighter disclosure norms for mutual fund expense ratios",
    "summary": "Revised disclosure expectations on total expense ratio (TER) and commissions. Useful background for retail investment-product topics.",
    "category": "Mutual Funds",
    "priority": "normal",
    "publishedAt": "2026-06-18",
    "sourceUrl": "https://www.sebi.gov.in/",
    "affectsTopics": ["mutual-funds", "investor-protection"]
  },
  {
    "id": "rbi-2026-06-12-kyc-md",
    "regulator": "RBI",
    "title": "Amendment to the Master Direction on KYC",
    "summary": "Updated periodic-KYC and customer due-diligence timelines. Affects KYC/AML topics in JAIIB Principles & Practices of Banking.",
    "category": "KYC / AML",
    "priority": "important",
    "publishedAt": "2026-06-12",
    "sourceUrl": "https://www.rbi.org.in/Scripts/BS_ViewMasDirections.aspx",
    "affectsTopics": ["kyc", "aml"]
  }
];

/**
 * Ingestion function: Add updates to Firestore.
 * Supports:
 * 1. POST with a list of updates in body: { updates: [...] }
 * 2. POST/GET with seed=true parameter to insert the predefined seed updates.
 */
exports.ingestUpdates = onRequest({ cors: true }, async (req, res) => {
  try {
    let updatesToIngest = [];

    if (req.method === "POST" && req.body && Array.isArray(req.body.updates)) {
      updatesToIngest = req.body.updates;
    } else if (req.query.seed === "true" || (req.body && req.body.seed === true)) {
      updatesToIngest = SEED_UPDATES;
    } else {
      res.status(400).json({
        error: "Invalid request. Please provide updates in the body or specify seed=true."
      });
      return;
    }

    const batch = db.batch();
    const collectionRef = db.collection("regulatory_updates");

    for (const update of updatesToIngest) {
      if (!update.id) {
        res.status(400).json({ error: "Each update must have an id." });
        return;
      }
      const docRef = collectionRef.doc(update.id);
      batch.set(docRef, {
        ...update,
        publishedAt: update.publishedAt || new Date().toISOString().split('T')[0]
      }, { merge: true });
    }

    await batch.commit();

    res.status(200).json({
      success: true,
      message: `Successfully ingested ${updatesToIngest.length} updates.`
    });
  } catch (error) {
    console.error("Error in ingestUpdates:", error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * Live Feed serving function: Retrieve updates from Firestore,
 * format them as an UpdatesFeed JSON payload, and return it.
 */
exports.updatesFeed = onRequest({ cors: true }, async (req, res) => {
  try {
    const snapshot = await db.collection("regulatory_updates").get();
    let updates = [];

    snapshot.forEach(doc => {
      updates.push(doc.data());
    });

    // Sort updates by publishedAt descending (newest first)
    updates.sort((a, b) => {
      const dateA = new Date(a.publishedAt);
      const dateB = new Date(b.publishedAt);
      return dateB - dateA;
    });

    // Note: the collection is populated by the live curation job
    // (refreshUpdates). If it's empty, the app falls back to its bundled seed,
    // so we no longer auto-seed placeholder data here.

    const feed = {
      version: 1,
      generatedAt: new Date().toISOString(),
      updates: updates
    };

    res.setHeader("Cache-Control", "public, max-age=60, s-maxage=120");
    res.status(200).json(feed);
  } catch (error) {
    console.error("Error in updatesFeed:", error);
    res.status(500).json({ error: error.message });
  }
});

// ── Live ingestion (Claude curation) ────────────────────────────────────────

const MODEL = "claude-opus-4-8";

// JSON-schema the curated output must conform to — mirrors RegulatoryUpdate in
// packages/app/lib/models/regulatory_update.dart.
const UPDATE_SCHEMA = {
  type: "object",
  additionalProperties: false,
  properties: {
    updates: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        properties: {
          regulator: { type: "string", enum: ["RBI", "SEBI", "IRDAI", "IIBF"] },
          title: { type: "string" },
          summary: { type: "string" },
          category: { type: "string" },
          priority: { type: "string", enum: ["critical", "important", "normal"] },
          publishedAt: { type: "string", format: "date" },
          sourceUrl: { type: "string", format: "uri" },
          affectsTopics: { type: "array", items: { type: "string" } },
        },
        required: [
          "regulator", "title", "summary", "category",
          "priority", "publishedAt", "sourceUrl", "affectsTopics",
        ],
      },
    },
  },
  required: ["updates"],
};

// Phase 1 — web research (free-form; lets the model search and take notes).
const RESEARCH_PROMPT = `You research regulatory updates for an Indian banking
certification study app (IIBF JAIIB/CAIIB candidates). Use web search to find
the most relevant official announcements from roughly the last 30 days from the
RBI, SEBI, IRDAI, and IIBF that matter to the JAIIB/CAIIB syllabus — monetary
policy, KYC/AML, digital lending, priority-sector lending, risk/capital norms,
mutual funds/investor protection, insurance regulation, and IIBF exam notices.

Search several times across the four regulators. Then write research notes
listing each real item you found, with: regulator, exact title, official source
URL (must be on rbi.org.in, sebi.gov.in, irdai.gov.in, or iibf.org.in),
publication date, and a one-line description. Only list items you actually found
via search with an attributable official URL — do not invent anything. If a
regulator yielded nothing, say so.`;

// Phase 2 — structure the notes into the strict schema (no tools, so structured
// outputs is honoured).
const STRUCTURE_PROMPT = `Convert the research notes below into the required JSON.
Include only items that have an official source URL on rbi.org.in, sebi.gov.in,
irdai.gov.in, or iibf.org.in. For each: a neutral 1-2 sentence summary; priority
(critical = exam notices/deadlines or major rule changes; important = notable
rule updates; normal = background); a short category label; publishedAt as
YYYY-MM-DD; and affectsTopics syllabus slugs. Newest first, up to 15 items. If
the notes contain no attributable items, return {"updates":[]}.

RESEARCH NOTES:
`;

// Drive the server-side web-search loop and return the model's research text.
async function researchUpdates(client) {
  const messages = [{ role: "user", content: RESEARCH_PROMPT }];
  let response;
  for (let i = 0; i < 6; i++) {
    response = await client.messages.create({
      model: MODEL,
      max_tokens: 16000,
      // Basic variant: no under-the-hood code execution / dynamic filtering.
      tools: [{ type: "web_search_20250305", name: "web_search", max_uses: 12 }],
      messages,
    });
    if (response.stop_reason !== "pause_turn") break;
    messages.push({ role: "assistant", content: response.content });
  }
  const blocks = response.content || [];
  const searchHits = blocks
    .filter((b) => b.type === "web_search_tool_result")
    .reduce((n, b) => n + (Array.isArray(b.content) ? b.content.length : 0), 0);
  const notes = blocks
    .filter((b) => b.type === "text")
    .map((b) => b.text)
    .join("\n");
  logger.info("researchUpdates", {
    stopReason: response.stop_reason,
    searchHits,
    notesPreview: notes.slice(0, 400),
  });
  return notes;
}

// Two-phase curation: research with web search, then structure into the schema.
async function curateUpdates() {
  const client = new Anthropic({ apiKey: ANTHROPIC_API_KEY.value() });

  const notes = await researchUpdates(client);
  if (!notes.trim()) return [];

  const structured = await client.messages.create({
    model: MODEL,
    max_tokens: 8000,
    output_config: { format: { type: "json_schema", schema: UPDATE_SCHEMA } },
    messages: [{ role: "user", content: STRUCTURE_PROMPT + notes }],
  });
  const textBlock = (structured.content || []).find((b) => b.type === "text");
  if (!textBlock) {
    throw new Error(`No structured output (stop_reason=${structured.stop_reason})`);
  }
  const parsed = JSON.parse(textBlock.text);
  return Array.isArray(parsed.updates) ? parsed.updates : [];
}

// Deterministic, stable id so re-curation merges rather than duplicates.
function updateId(u) {
  const hash = crypto
    .createHash("sha1")
    .update(u.sourceUrl || u.title)
    .digest("hex")
    .slice(0, 8);
  return `${u.regulator.toLowerCase()}-${u.publishedAt}-${hash}`;
}

// Skip curation if the feed was refreshed within this window, to avoid
// unnecessary (metered) web searches.
const FRESHNESS_WINDOW_MS = 6 * 60 * 60 * 1000;
const META_REF = () => db.collection("regulatory_updates_meta").doc("state");

// Curate, write to Firestore (merge by id), and FCM-notify on new high-priority
// items. Skips the web-search call when the feed is still fresh (< 6h old)
// unless { force } is set. Returns a small summary object.
async function curateAndStore({ force = false } = {}) {
  if (!force) {
    const meta = await META_REF().get();
    const lastMs = meta.exists ? meta.get("lastRefreshedAt") : null;
    if (typeof lastMs === "number") {
      const ageMs = Date.now() - lastMs;
      if (ageMs < FRESHNESS_WINDOW_MS) {
        return {
          skipped: true,
          reason: "fresh",
          ageMinutes: Math.round(ageMs / 60000),
        };
      }
    }
  }

  const updates = await curateUpdates();
  const collection = db.collection("regulatory_updates");
  const batch = db.batch();
  const newHighPriority = [];

  for (const u of updates) {
    const id = updateId(u);
    const ref = collection.doc(id);
    const existing = await ref.get();
    if (!existing.exists && (u.priority === "critical" || u.priority === "important")) {
      newHighPriority.push(u);
    }
    batch.set(ref, { ...u, id }, { merge: true });
  }
  await batch.commit();
  await META_REF().set({ lastRefreshedAt: Date.now() }, { merge: true });

  if (newHighPriority.length > 0) {
    const top = newHighPriority[0];
    await admin.messaging().send({
      topic: "regulatory-updates",
      notification: {
        title: `${top.regulator}: ${top.title}`,
        body:
          newHighPriority.length > 1
            ? `${top.summary} (+${newHighPriority.length - 1} more)`
            : top.summary,
      },
    });
  }

  return { curated: updates.length, notified: newHighPriority.length };
}

// Daily scheduled curation (08:30 IST).
exports.refreshUpdates = onSchedule(
  {
    schedule: "30 8 * * *",
    timeZone: "Asia/Kolkata",
    secrets: [ANTHROPIC_API_KEY],
    timeoutSeconds: 300,
    memory: "512MiB",
  },
  async () => {
    const result = await curateAndStore();
    logger.info("refreshUpdates", result);
  }
);

// Manual trigger for testing / backfill: GET/POST the function URL.
exports.refreshUpdatesNow = onRequest(
  { secrets: [ANTHROPIC_API_KEY], timeoutSeconds: 300, memory: "512MiB" },
  async (req, res) => {
    try {
      // Pass ?force=true to bypass the 6h freshness guard (backfill/testing).
      const force = req.query.force === "true" || req.body?.force === true;
      const result = await curateAndStore({ force });
      res.status(200).json({ success: true, ...result });
    } catch (error) {
      logger.error("refreshUpdatesNow failed", error);
      res.status(500).json({ error: error.message });
    }
  }
);
