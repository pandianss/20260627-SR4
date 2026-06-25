#!/usr/bin/env node
// tools/migrate_content.js
//
// One-shot content enrichment script.
// Reads content_pack_caiib.json and enriches each lesson's cards with:
//   1. `formula` blocks — extracted from highlight: fields in concept steps
//   2. `chart` blocks  — injected for key quantitative lessons
//
// Run: node tools/migrate_content.js
// Output: packages/app/assets/content_pack_caiib.json (in-place update)
//
// NOTE: The script is idempotent — running twice won't duplicate blocks
//       because it checks for existing formula/chart blocks before inserting.

const fs = require('fs');
const path = require('path');

const ASSET_PATH = path.join(
  __dirname, '..', 'packages', 'app', 'assets', 'content_pack_caiib.json'
);

// ─── Chart specs for key quantitative lessons ─────────────────────────────────
// These are the "hand-authored" chart specs that map lesson content to chart blocks.
// keyed by lessonId → list of { afterCardId, spec }
const CHART_INJECTIONS = {
  'L-BFM-B1': [
    {
      // Insert stacked_bar after the first card (Capital Adequacy concept)
      afterCardIndex: 0,
      cardId: 'L-BFM-B1_chart_capital',
      spec: {
        type: 'stacked_bar',
        title: 'RBI Capital Requirements (% of RWA)',
        unit: '%',
        groups: [
          {
            label: 'CET1 Min',
            layers: [
              { label: 'CET1', value: 5.5, color: '#2DD4BF' }
            ]
          },
          {
            label: 'Tier 1 Min',
            layers: [
              { label: 'CET1', value: 5.5, color: '#2DD4BF' },
              { label: 'AT1', value: 1.5, color: '#60A5FA' }
            ]
          },
          {
            label: 'Total Capital',
            layers: [
              { label: 'CET1', value: 5.5, color: '#2DD4BF' },
              { label: 'AT1', value: 1.5, color: '#60A5FA' },
              { label: 'Tier 2', value: 2.0, color: '#FB923C' }
            ]
          },
          {
            label: 'With CCB',
            layers: [
              { label: 'CET1', value: 5.5, color: '#2DD4BF' },
              { label: 'AT1', value: 1.5, color: '#60A5FA' },
              { label: 'Tier 2', value: 2.0, color: '#FB923C' },
              { label: 'CCB', value: 2.5, color: '#A78BFA' }
            ]
          }
        ]
      }
    }
  ],
  'L-BFM-D1': [
    {
      afterCardIndex: 0,
      cardId: 'L-BFM-D1_chart_lcr',
      spec: {
        type: 'threshold_line',
        title: 'LCR — Bank Gamma Example',
        unit: '%',
        max: 150,
        bars: [
          { label: 'Bank Gamma LCR', value: 125, color: '#60A5FA' }
        ],
        thresholds: [
          { label: 'RBI Min', value: 100, color: '#EF4444' }
        ]
      }
    }
  ],
  'L-ABM-C1': [
    {
      afterCardIndex: 0,
      cardId: 'L-ABM-C1_chart_mpbf',
      spec: {
        type: 'bars',
        title: 'MPBF Method II — Working Capital (₹ Lakhs)',
        unit: ' L',
        items: [
          { label: 'Current Assets', value: 800 },
          { label: 'Borrower Margin (25%)', value: 200 },
          { label: 'Bank Finance (MPBF)', value: 400 },
          { label: 'Other CL', value: 200 }
        ]
      }
    }
  ],
  'L-ABFM-B1': [
    {
      afterCardIndex: 0,
      cardId: 'L-ABFM-B1_chart_capm',
      spec: {
        type: 'bars',
        title: 'CAPM Build-Up — Example Project (β=1.25)',
        unit: '%',
        items: [
          { label: 'Risk-Free Rate (Rf)', value: 7.0 },
          { label: 'Market Premium (Rm−Rf)', value: 6.0 },
          { label: 'Equity Risk Prem (β×MRP)', value: 7.5 },
          { label: 'Cost of Equity (Ke)', value: 14.5 }
        ]
      }
    }
  ],
  'L-ABM-A1': [
    {
      afterCardIndex: 0,
      cardId: 'L-ABM-A1_chart_gdp',
      spec: {
        type: 'bars',
        title: 'PMI Signal Interpretation',
        unit: '',
        items: [
          { label: 'PMI > 50 (Expansion)', value: 55 },
          { label: 'PMI = 50 (Neutral)', value: 50 },
          { label: 'PMI < 50 (Contraction)', value: 45 }
        ]
      }
    }
  ]
};

// ─── Formula extraction helpers ────────────────────────────────────────────────

/**
 * Convert a highlight text like "CET1: 5.5% | Tier 1: 7.0% | Total: 9.0%"
 * into a LaTeX-style formula string suitable for a formula block.
 * 
 * Rules:
 *  - pipe (|) → newline separator
 *  - "Key: value%" → rendered as "Key = value\%"  
 *  - fractions like "X/Y" → \frac{X}{Y}
 *  - known symbols mapped
 */
function highlightToLatex(highlight) {
  if (!highlight) return null;
  
  // If highlight already contains a fraction (/) we render as LaTeX
  // Otherwise render as a multi-part expression
  const parts = highlight.split('|').map(p => p.trim()).filter(Boolean);
  
  if (parts.length === 1) {
    return convertPart(parts[0]);
  }
  
  // Multi-part: join with \quad separator
  return parts.map(convertPart).join(' \\quad ');
}

function convertPart(part) {
  let r = part.trim();
  
  // "Key = A / B" or "Key = A/B" → \frac form
  const fracMatch = r.match(/^(.*?)\s*=\s*([\d.,₹]+)\s*\/\s*([\d.,₹\s\w]+)$/);
  if (fracMatch) {
    const label = fracMatch[1].trim();
    const num = fracMatch[2].trim();
    const den = fracMatch[3].trim();
    return label ? `${label} = \\frac{${num}}{${den}}` : `\\frac{${num}}{${den}}`;
  }
  
  // "Key: value" or "Key = value"
  r = r.replace(/:\s+/g, ' = ');
  r = r.replace(/%/g, '\\%');
  r = r.replace(/≥/g, '\\ge');
  r = r.replace(/≤/g, '\\le');
  r = r.replace(/×/g, '\\times');
  r = r.replace(/±/g, '\\pm');
  
  return r;
}

// ─── Block construction ───────────────────────────────────────────────────────

function makeFormulaBlock(latex) {
  return { kind: 'formula', latex };
}

function makeChartBlock(spec) {
  return { kind: 'chart', spec };
}

function makeTextBlock(text) {
  return { kind: 'text', md: { en: text } };
}

// ─── Card enrichment ──────────────────────────────────────────────────────────

/**
 * Enrich a single lesson object in-place.
 * Returns { formulasAdded, chartsAdded } counts.
 */
function enrichLesson(lesson, chartInjections) {
  let formulasAdded = 0;
  let chartsAdded = 0;

  const cards = lesson.cards || [];

  // 1. Formula pass — scan text blocks for highlight-style content
  //    The existing content pack stores concept body + highlight as a single
  //    text block with a > prefix or a trailing line starting with highlight:
  //    We look for lines that look like "A = B | C = D" formula patterns.
  for (const card of cards) {
    const blocks = card.blocks || [];
    const newBlocks = [];
    
    for (let i = 0; i < blocks.length; i++) {
      const block = blocks[i];
      newBlocks.push(block);
      
      if (block.kind === 'text') {
        const text = (block.md && (block.md.en || block.md)) || '';
        
        // Look for a line that looks like a "highlight" formula line:
        // - Contains | separator with = signs (multi-expression)
        // - Or contains a fraction pattern: X/Y = Z
        // - But NOT already followed by a formula block
        const nextBlock = blocks[i + 1];
        const alreadyHasFormula = nextBlock && nextBlock.kind === 'formula';
        
        if (!alreadyHasFormula) {
          const lines = text.split('\n');
          // Find lines that are clearly formula/highlight style
          const formulaLine = lines.find(line => {
            const t = line.trim();
            // Must contain = and either | or / or % and not be a sentence
            return (
              t.includes('=') &&
              (t.includes('|') || t.includes('/') || t.includes('%')) &&
              t.length < 200 &&
              !t.startsWith('- ') &&
              !t.startsWith('•') &&
              // Not a step description (shouldn't have too many lowercase words)
              (t.match(/[A-Z0-9]/g) || []).length > t.length * 0.1
            );
          });
          
          if (formulaLine) {
            const latex = highlightToLatex(formulaLine.trim());
            if (latex && latex.length > 3) {
              newBlocks.push(makeFormulaBlock(latex));
              formulasAdded++;
            }
          }
        }
      }
    }
    
    card.blocks = newBlocks;
  }

  // 2. Chart injection pass
  if (chartInjections && chartInjections.length > 0) {
    for (const injection of chartInjections) {
      const { afterCardIndex, cardId, spec } = injection;
      
      // Check if chart card already exists
      const alreadyExists = cards.some(c => c.id === cardId);
      if (alreadyExists) continue;
      
      const chartCard = {
        id: cardId,
        kind: 'example',
        srsEligible: false,
        blocks: [makeChartBlock(spec)]
      };
      
      const insertAt = Math.min(afterCardIndex + 1, cards.length);
      cards.splice(insertAt, 0, chartCard);
      chartsAdded++;
    }
  }

  return { formulasAdded, chartsAdded };
}

// ─── Main ─────────────────────────────────────────────────────────────────────

function main() {
  console.log('📖  Reading content pack…');
  const raw = fs.readFileSync(ASSET_PATH, 'utf8');
  const pack = JSON.parse(raw);

  const lessons = pack.lessons || [];
  console.log(`    Found ${lessons.length} lessons.`);

  let totalFormulas = 0;
  let totalCharts = 0;
  let enrichedCount = 0;

  for (const lesson of lessons) {
    const injections = CHART_INJECTIONS[lesson.id] || null;
    const { formulasAdded, chartsAdded } = enrichLesson(lesson, injections);
    if (formulasAdded > 0 || chartsAdded > 0) {
      enrichedCount++;
      totalFormulas += formulasAdded;
      totalCharts += chartsAdded;
      if (chartsAdded > 0 || formulasAdded > 0) {
        console.log(`  ✓ ${lesson.id}: +${formulasAdded} formula(s), +${chartsAdded} chart(s)`);
      }
    }
  }

  console.log('');
  console.log(`✅  Enriched ${enrichedCount} lessons.`);
  console.log(`    Total formula blocks added : ${totalFormulas}`);
  console.log(`    Total chart blocks added   : ${totalCharts}`);
  console.log('');
  console.log('💾  Writing enriched content pack…');

  const output = JSON.stringify(pack, null, 2);
  fs.writeFileSync(ASSET_PATH, output, 'utf8');

  const sizeMb = (Buffer.byteLength(output, 'utf8') / 1024 / 1024).toFixed(2);
  console.log(`    Written ${sizeMb} MB → ${ASSET_PATH}`);
  console.log('');
  console.log('Done. Re-run "flutter build apk" to bundle the updated content pack.');
}

main();
