const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

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

    // In case collection is empty, seed it automatically so it functions out of the box
    if (updates.length === 0) {
      const batch = db.batch();
      const collectionRef = db.collection("regulatory_updates");
      for (const update of SEED_UPDATES) {
        batch.set(collectionRef.doc(update.id), update);
      }
      await batch.commit();
      updates = [...SEED_UPDATES];
      updates.sort((a, b) => new Date(b.publishedAt) - new Date(a.publishedAt));
    }

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
