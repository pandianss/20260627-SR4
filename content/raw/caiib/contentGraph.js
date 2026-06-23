// CAIIB Syllabus Content Graph
// Contains Subjects, Modules, Topics, MicroLessons, Formulas, and RBI Circular links.

export const SUBJECTS = [
  { id: "ABM",  label: "ABM",  name: "Advanced Bank Management", color: "#2DD4BF" },
  { id: "BFM",  label: "BFM",  name: "Bank Financial Management", color: "#60A5FA" },
  { id: "ABFM", label: "ABFM", name: "Adv. Business & Financial Mgmt", color: "#FB923C" },
  { id: "BRBL", label: "BRBL", name: "Banking Regulations & Laws", color: "#A78BFA" },
];

export const ELECTIVES = [
  { id: "Risk",    label: "Risk",    name: "Risk Management", color: "#EAB308" },
  { id: "IT",      label: "IT",      name: "IT & Digital Banking", color: "#10B981" },
  { id: "HR",      label: "HR",      name: "Human Resource Management", color: "#8B5CF6" },
  { id: "Rural",   label: "Rural",   name: "Rural Banking", color: "#F43F5E" },
  { id: "Central", label: "Central", name: "Central Banking", color: "#EC4899" }
];

export const MODULES = {
  ABM: [
    { id: "ABM-A", name: "Module A: Economic Analysis" },
    { id: "ABM-B", name: "Module B: Human Resource Management" },
    { id: "ABM-C", name: "Module C: Credit Management" },
    { id: "ABM-D", name: "Module D: Compliance & Governance" },
    { id: "ABM-E", name: "Module E: Business Mathematics" }
  ],
  BFM: [
    { id: "BFM-A", name: "Module A: International Banking" },
    { id: "BFM-B", name: "Module B: Risk Management" },
    { id: "BFM-C", name: "Module C: Treasury Management" },
    { id: "BFM-D", name: "Module D: Balance Sheet Management" }
  ],
  ABFM: [
    { id: "ABFM-A", name: "Module A: Management Process" },
    { id: "ABFM-B", name: "Module B: Advanced Financial Management" },
    { id: "ABFM-C", name: "Module C: Valuation, Mergers & Acquisitions" },
    { id: "ABFM-D", name: "Module D: Project Finance" }
  ],
  BRBL: [
    { id: "BRBL-A", name: "Module A: Regulatory Framework of Banking" },
    { id: "BRBL-B", name: "Module B: Legal Aspects of Banking Operations" },
    { id: "BRBL-C", name: "Module C: Banking Related Laws" },
    { id: "BRBL-D", name: "Module D: Commercial Laws" }
  ],
  Risk: [
    { id: "Risk-A", name: "Module A: An Overview of Risk" },
    { id: "Risk-B", name: "Module B: Credit Risk Measurement" },
    { id: "Risk-C", name: "Module C: Market Risk & Operational Risk" },
    { id: "Risk-D", name: "Module D: Risk Organization & Policy" }
  ],
  Rural: [
    { id: "Rural-A", name: "Module A: Rural India" },
    { id: "Rural-B", name: "Module B: Financing Rural Development" },
    { id: "Rural-C", name: "Module C: Priority Sector Financing" },
    { id: "Rural-D", name: "Module D: Challenges in Rural Banking" }
  ],
  Central: [
    { id: "Central-A", name: "Module A: Rationale & Functions of Central Bank" },
    { id: "Central-B", name: "Module B: Central Banking in India" },
    { id: "Central-C", name: "Module C: Monetary & Credit Policies" },
    { id: "Central-D", name: "Module D: Forex Reserve Management" },
    { id: "Central-E", name: "Module E: Regulation and Supervision" },
    { id: "Central-F", name: "Module F: NBFCs and Primary Dealers" }
  ],
  IT: [
    { id: "IT-A", name: "Module A: Information Technology in Banking" },
    { id: "IT-B", name: "Module B: Core Banking & Payment Systems" },
    { id: "IT-C", name: "Module C: Digital Banking Security" },
    { id: "IT-D", name: "Module D: Analytics & Emerging Tech" }
  ],
  HR: [
    { id: "HR-A", name: "Module A: HRM Concepts & Organization" },
    { id: "HR-B", name: "Module B: Training, Development & Career Path" },
    { id: "HR-C", name: "Module C: Performance & Compensation" },
    { id: "HR-D", name: "Module D: Industrial Relations & Discipline" }
  ]
};

export const TOPICS = {

  // ════════════════════════════════════════════════════════
  //  ABM — Advanced Bank Management
  // ════════════════════════════════════════════════════════
  "ABM-A": [
    { id: "T-ABM-A1",  name: "Business Cycles & GDP Trends",                          weightage: "High",     dependency: [] },
    { id: "T-ABM-A2",  name: "Inflation Mechanics (CPI vs WPI)",                      weightage: "High",     dependency: [] },
    { id: "T-ABM-A3",  name: "Union Budget, Fiscal Policy & FRBM",                    weightage: "High",     dependency: ["T-ABM-A1"] },
    { id: "T-ABM-A4",  name: "Demand, Supply & Price Elasticity",                     weightage: "Medium",   dependency: [] },
    { id: "T-ABM-A5",  name: "National Income Accounting (GDP, GNP, NNP, NDP)",       weightage: "High",     dependency: [] },
    { id: "T-ABM-A6",  name: "Money Supply & Monetary Aggregates (M0–M4)",            weightage: "Critical", dependency: [] },
    { id: "T-ABM-A7",  name: "Monetary Policy — Instruments & Transmission",          weightage: "Critical", dependency: ["T-ABM-A6"] },
    { id: "T-ABM-A8",  name: "Balance of Payments — Current & Capital Account",       weightage: "High",     dependency: [] },
    { id: "T-ABM-A9",  name: "Foreign Exchange Rate Determination",                   weightage: "High",     dependency: ["T-ABM-A8"] },
    { id: "T-ABM-A10", name: "Economic Reforms — LPG, Financial Sector Liberalisation", weightage: "Medium", dependency: [] },
    { id: "T-ABM-A11", name: "Indian Financial System — RBI, SEBI, IRDAI, PFRDA",    weightage: "Medium",   dependency: [] }
  ],
  "ABM-B": [
    { id: "T-ABM-B1",  name: "HR Planning & Recruitment in Banks",                    weightage: "Medium",   dependency: [] },
    { id: "T-ABM-B2",  name: "Training, Development & Performance Appraisal",         weightage: "Medium",   dependency: ["T-ABM-B1"] },
    { id: "T-ABM-B3",  name: "Motivation Theories & Leadership Styles",               weightage: "Medium",   dependency: [] },
    { id: "T-ABM-B4",  name: "Organisational Behaviour & Change Management",          weightage: "Medium",   dependency: [] },
    { id: "T-ABM-B5",  name: "Job Analysis, Job Description & Job Evaluation",        weightage: "Low",      dependency: [] },
    { id: "T-ABM-B6",  name: "Compensation Management & Wage Theories",               weightage: "Medium",   dependency: [] },
    { id: "T-ABM-B7",  name: "Industrial Relations & Trade Union Act 1926",           weightage: "High",     dependency: [] },
    { id: "T-ABM-B8",  name: "Industrial Disputes Act 1947",                          weightage: "High",     dependency: ["T-ABM-B7"] },
    { id: "T-ABM-B9",  name: "Grievance Handling & Disciplinary Procedures",          weightage: "Medium",   dependency: ["T-ABM-B8"] },
    { id: "T-ABM-B10", name: "Employee Welfare, Social Security & Factories Act",     weightage: "Medium",   dependency: [] },
    { id: "T-ABM-B11", name: "Collective Bargaining & Wage Settlements in Banks",     weightage: "Medium",   dependency: ["T-ABM-B7"] }
  ],
  "ABM-C": [
    { id: "T-ABM-C1",  name: "Working Capital Assessment (Nayak & Tandon Methods)",   weightage: "Critical", dependency: [] },
    { id: "T-ABM-C2",  name: "NPA Classification, Provisioning & Resolution",         weightage: "Critical", dependency: [] },
    { id: "T-ABM-C3",  name: "Credit Risk Rating & Risk-Based Pricing",               weightage: "High",     dependency: ["T-ABM-C1"] },
    { id: "T-ABM-C4",  name: "Financial Statement Analysis for Credit",               weightage: "Critical", dependency: [] },
    { id: "T-ABM-C5",  name: "Term Loan Appraisal & Project Finance",                 weightage: "Critical", dependency: ["T-ABM-C1"] },
    { id: "T-ABM-C6",  name: "DSCR, LLCR & Project Viability Assessment",            weightage: "Critical", dependency: ["T-ABM-C5"] },
    { id: "T-ABM-C7",  name: "Letters of Credit — Types, UCP 600 & Operations",       weightage: "High",     dependency: [] },
    { id: "T-ABM-C8",  name: "Bank Guarantees — Types, Invocation & Risk",            weightage: "High",     dependency: [] },
    { id: "T-ABM-C9",  name: "Consortium Lending & Multiple Banking Arrangements",    weightage: "Medium",   dependency: ["T-ABM-C1"] },
    { id: "T-ABM-C10", name: "Priority Sector Lending — Targets & Sub-targets",       weightage: "Critical", dependency: [] },
    { id: "T-ABM-C11", name: "Agricultural Credit — KCC, Crop Loans & Land Dev.",     weightage: "High",     dependency: ["T-ABM-C10"] },
    { id: "T-ABM-C12", name: "MSME Credit — Udyam, CGTMSE & Stand-up India",         weightage: "High",     dependency: ["T-ABM-C10"] }
  ],
  "ABM-D": [
    { id: "T-ABM-D1",  name: "KYC / AML Framework — PMLA & FIU-IND",                 weightage: "Critical", dependency: [] },
    { id: "T-ABM-D2",  name: "Corporate Governance in Banks",                         weightage: "High",     dependency: [] },
    { id: "T-ABM-D3",  name: "Fraud Risk Management & Vigilance (CVC/CVO)",           weightage: "High",     dependency: ["T-ABM-D1"] },
    { id: "T-ABM-D4",  name: "FEMA — Current & Capital Account Transactions",         weightage: "High",     dependency: [] },
    { id: "T-ABM-D5",  name: "Banking Ombudsman Scheme & Grievance Redressal",        weightage: "High",     dependency: [] },
    { id: "T-ABM-D6",  name: "Fair Practices Code & Consumer Protection Act 2019",    weightage: "Medium",   dependency: [] },
    { id: "T-ABM-D7",  name: "Basel Pillar 2 — ICAAP & Risk-Based Supervision",       weightage: "High",     dependency: [] },
    { id: "T-ABM-D8",  name: "Prompt Corrective Action (PCA) Framework",              weightage: "High",     dependency: ["T-ABM-D7"] },
    { id: "T-ABM-D9",  name: "Right to Information Act 2005 & Data Privacy",          weightage: "Low",      dependency: [] }
  ],
  "ABM-E": [
    { id: "T-ABM-E1", name: "Time Value of Money — Compounding, Discounting & Future Value",  weightage: "Critical", dependency: [] },
    { id: "T-ABM-E2", name: "EMI, Annuities & Loan Amortisation",                             weightage: "Critical", dependency: ["T-ABM-E1"] },
    { id: "T-ABM-E3", name: "Statistics — Measures of Central Tendency",                       weightage: "High",     dependency: [] },
    { id: "T-ABM-E4", name: "Measures of Dispersion — Variance, SD & Coefficient of Variation", weightage: "High",   dependency: ["T-ABM-E3"] },
    { id: "T-ABM-E5", name: "Probability Theory — Rules, Conditional & Bayes' Theorem",        weightage: "High",    dependency: [] },
    { id: "T-ABM-E6", name: "Probability Distributions — Normal, Binomial & Poisson",          weightage: "High",    dependency: ["T-ABM-E5"] },
    { id: "T-ABM-E7", name: "Correlation & Regression Analysis",                               weightage: "High",    dependency: [] },
    { id: "T-ABM-E8", name: "Index Numbers & Linear Programming",                              weightage: "Medium",   dependency: [] }
  ],

  // ════════════════════════════════════════════════════════
  //  BFM — Bank Financial Management
  // ════════════════════════════════════════════════════════
  "BFM-A": [
    { id: "T-BFM-A1",  name: "Foreign Exchange Market — Structure & Participants",    weightage: "High",     dependency: [] },
    { id: "T-BFM-A2",  name: "Exchange Rate Quotations — Direct, Indirect, Cross Rates", weightage: "Critical", dependency: ["T-BFM-A1"] },
    { id: "T-BFM-A3",  name: "Exchange Rate Determination — PPP, IRP & BOP Theory",  weightage: "High",     dependency: ["T-BFM-A2"] },
    { id: "T-BFM-A4",  name: "Forward Exchange Contracts & Currency Hedging",         weightage: "Critical", dependency: ["T-BFM-A2"] },
    { id: "T-BFM-A5",  name: "NOSTRO, VOSTRO & LORO Accounts",                        weightage: "High",     dependency: [] },
    { id: "T-BFM-A6",  name: "Letters of Credit — UCP 600, Types & Lifecycle",        weightage: "Critical", dependency: [] },
    { id: "T-BFM-A7",  name: "Bank Guarantees & Standby Letters of Credit",           weightage: "High",     dependency: [] },
    { id: "T-BFM-A8",  name: "Export Finance — PCFC, EPC & Post-shipment Credit",     weightage: "High",     dependency: ["T-BFM-A5"] },
    { id: "T-BFM-A9",  name: "Import Finance — Buyer's Credit & Supplier's Credit",   weightage: "Medium",   dependency: ["T-BFM-A6"] },
    { id: "T-BFM-A10", name: "FEMA — Authorised Dealer Categories & Remittances",     weightage: "High",     dependency: [] },
    { id: "T-BFM-A11", name: "SWIFT, Correspondent Banking & International Settlements", weightage: "Medium", dependency: [] }
  ],
  "BFM-B": [
    { id: "T-BFM-B1",  name: "Basel III Capital Adequacy — CRAR, CET1, Buffers",      weightage: "Critical", dependency: [] },
    { id: "T-BFM-B2",  name: "Value at Risk (VaR) — Models & Interpretation",         weightage: "Critical", dependency: [] },
    { id: "T-BFM-B3",  name: "Operational Risk — BIA, TSA, AMA & Loss Categories",    weightage: "High",     dependency: ["T-BFM-B1"] },
    { id: "T-BFM-B4",  name: "Credit Risk Metrics — PD, LGD, EAD & Expected Loss",   weightage: "Critical", dependency: ["T-BFM-B1"] },
    { id: "T-BFM-B5",  name: "Credit Risk Mitigation — Collateral, Netting & CDS",   weightage: "High",     dependency: ["T-BFM-B4"] },
    { id: "T-BFM-B6",  name: "Market Risk — Sensitivity, Greeks & Stress Testing",    weightage: "High",     dependency: ["T-BFM-B2"] },
    { id: "T-BFM-B7",  name: "Basel III Leverage Ratio & Capital Buffers (CCB, CCyB, D-SIB)", weightage: "High", dependency: ["T-BFM-B1"] },
    { id: "T-BFM-B8",  name: "Large Exposure Framework & Concentration Risk",         weightage: "Medium",   dependency: ["T-BFM-B4"] },
    { id: "T-BFM-B9",  name: "ICAAP — Internal Capital Adequacy Assessment",          weightage: "High",     dependency: ["T-BFM-B1"] }
  ],
  "BFM-C": [
    { id: "T-BFM-C1",  name: "Treasury Organisation — Front, Mid & Back Office",      weightage: "Medium",   dependency: [] },
    { id: "T-BFM-C2",  name: "Money Market Instruments — T-Bills, CPs, CDs, Repos",  weightage: "Critical", dependency: [] },
    { id: "T-BFM-C3",  name: "Government Securities — G-Secs, SDLs, T-Bills, FRBs", weightage: "Critical", dependency: [] },
    { id: "T-BFM-C4",  name: "Bond Pricing, YTM & Yield Curve Shapes",               weightage: "Critical", dependency: ["T-BFM-C3"] },
    { id: "T-BFM-C5",  name: "Duration, Modified Duration & Convexity",              weightage: "Critical", dependency: ["T-BFM-C4"] },
    { id: "T-BFM-C6",  name: "Interest Rate Derivatives — FRAs, IRF & Interest Rate Swaps", weightage: "High", dependency: ["T-BFM-C5"] },
    { id: "T-BFM-C7",  name: "Equity & Currency Derivatives for Bankers",             weightage: "Medium",   dependency: [] },
    { id: "T-BFM-C8",  name: "Investment Portfolio — HTM, AFS, HFT Classification & Valuation", weightage: "Critical", dependency: ["T-BFM-C3"] },
    { id: "T-BFM-C9",  name: "ALCO — Functions, Reporting & Limit Setting",           weightage: "High",     dependency: [] },
    { id: "T-BFM-C10", name: "Funds Transfer Pricing (FTP) & Internal Benchmarking", weightage: "Medium",   dependency: ["T-BFM-C9"] }
  ],
  "BFM-D": [
    { id: "T-BFM-D1",  name: "Liquidity Coverage Ratio (LCR) — HQLA & Net Outflows", weightage: "Critical", dependency: ["T-BFM-B1"] },
    { id: "T-BFM-D2",  name: "Interest Rate Risk in Banking Book (IRRBB) & ALM",      weightage: "Critical", dependency: [] },
    { id: "T-BFM-D3",  name: "Net Stable Funding Ratio (NSFR)",                       weightage: "High",     dependency: ["T-BFM-D1"] },
    { id: "T-BFM-D4",  name: "Gap Analysis — Rate Sensitive Assets & Liabilities",   weightage: "Critical", dependency: ["T-BFM-D2"] },
    { id: "T-BFM-D5",  name: "Earnings at Risk (EaR) & NII Sensitivity Analysis",    weightage: "High",     dependency: ["T-BFM-D4"] },
    { id: "T-BFM-D6",  name: "Economic Value of Equity (EVE) & Duration Gap",        weightage: "High",     dependency: ["T-BFM-D4"] },
    { id: "T-BFM-D7",  name: "Stress Testing in Banks — Types & RBI Requirements",   weightage: "High",     dependency: [] },
    { id: "T-BFM-D8",  name: "Capital Planning, RWA Management & ICAAP Integration", weightage: "High",     dependency: ["T-BFM-B1"] },
    { id: "T-BFM-D9",  name: "Performance Metrics — NIM, ROA, ROE, RAROC",           weightage: "High",     dependency: [] }
  ],

  // ════════════════════════════════════════════════════════
  //  ABFM — Advanced Business & Financial Management
  // ════════════════════════════════════════════════════════
  "ABFM-A": [
    { id: "T-ABFM-A1", name: "Strategic Management — SWOT, PESTLE, Porter's Five Forces", weightage: "High",   dependency: [] },
    { id: "T-ABFM-A2", name: "BCG Matrix, GE-McKinsey Matrix & Strategic Portfolio",  weightage: "Medium",   dependency: ["T-ABFM-A1"] },
    { id: "T-ABFM-A3", name: "Corporate Planning, Budgeting & MBO",                   weightage: "Medium",   dependency: [] },
    { id: "T-ABFM-A4", name: "Balanced Scorecard & Management Control Systems",       weightage: "High",     dependency: [] },
    { id: "T-ABFM-A5", name: "Decision Making — Quantitative Models & Decision Trees", weightage: "Medium",  dependency: [] },
    { id: "T-ABFM-A6", name: "Project Management — CPM, PERT & Gantt Charts",         weightage: "High",     dependency: [] },
    { id: "T-ABFM-A7", name: "TQM, Six Sigma, Lean & BPR",                            weightage: "Medium",   dependency: [] },
    { id: "T-ABFM-A8", name: "Marketing Management — STP, 4Ps & CRM for Banks",       weightage: "Medium",   dependency: [] },
    { id: "T-ABFM-A9", name: "Operations & Supply Chain Management",                  weightage: "Low",      dependency: [] }
  ],
  "ABFM-B": [
    { id: "T-ABFM-B1", name: "Capital Asset Pricing Model (CAPM)",                    weightage: "Critical", dependency: [] },
    { id: "T-ABFM-B2", name: "Capital Budgeting — NPV, IRR, MIRR & Payback",          weightage: "Critical", dependency: [] },
    { id: "T-ABFM-B3", name: "Weighted Average Cost of Capital (WACC)",               weightage: "Critical", dependency: ["T-ABFM-B1"] },
    { id: "T-ABFM-B4", name: "Portfolio Theory — Markowitz, Efficient Frontier & Beta", weightage: "High",   dependency: ["T-ABFM-B1"] },
    { id: "T-ABFM-B5", name: "Capital Structure Theories — MM Theorem, Trade-off, Pecking Order", weightage: "High", dependency: ["T-ABFM-B3"] },
    { id: "T-ABFM-B6", name: "Dividend Policy — Gordon's Model, Walter's Model, MM Irrelevance", weightage: "High", dependency: [] },
    { id: "T-ABFM-B7", name: "Working Capital Management — Cash, Receivables, Inventory", weightage: "Critical", dependency: [] },
    { id: "T-ABFM-B8", name: "Derivatives for Corporate Finance — Options, Futures, Swaps", weightage: "Medium", dependency: [] }
  ],
  "ABFM-C": [
    { id: "T-ABFM-C1", name: "Business Valuation — DCF, Multiples & Asset-based",     weightage: "Critical", dependency: ["T-ABFM-B2"] },
    { id: "T-ABFM-C2", name: "Free Cash Flow — FCFF & FCFE Computation",              weightage: "Critical", dependency: ["T-ABFM-C1"] },
    { id: "T-ABFM-C3", name: "Enterprise Value vs. Equity Value & EV Multiples",      weightage: "High",     dependency: ["T-ABFM-C1"] },
    { id: "T-ABFM-C4", name: "Mergers & Acquisitions — Types, Rationale & Process",   weightage: "High",     dependency: [] },
    { id: "T-ABFM-C5", name: "M&A Due Diligence — Financial, Legal & Commercial",     weightage: "High",     dependency: ["T-ABFM-C4"] },
    { id: "T-ABFM-C6", name: "SEBI Takeover Code (SAST Regulations 2011)",            weightage: "High",     dependency: ["T-ABFM-C4"] },
    { id: "T-ABFM-C7", name: "Post-Merger Integration & Synergy Realisation",         weightage: "Medium",   dependency: ["T-ABFM-C4"] },
    { id: "T-ABFM-C8", name: "Leveraged Buyouts (LBOs) & Private Equity Basics",      weightage: "Medium",   dependency: [] },
    { id: "T-ABFM-C9", name: "Corporate Restructuring — Demerger, Spin-off, Buyback", weightage: "Medium",   dependency: [] }
  ],
  "ABFM-D": [
    { id: "T-ABFM-D1", name: "Project Finance vs. Corporate Finance — Structure & SPV", weightage: "Critical", dependency: [] },
    { id: "T-ABFM-D2", name: "Project Appraisal — Technical, Financial, Economic & Social", weightage: "Critical", dependency: ["T-ABFM-D1"] },
    { id: "T-ABFM-D3", name: "DSCR, LLCR & PLCR in Infrastructure Finance",           weightage: "Critical", dependency: ["T-ABFM-D2"] },
    { id: "T-ABFM-D4", name: "Financial Modelling for Projects — Sensitivity & Scenarios", weightage: "High", dependency: ["T-ABFM-D3"] },
    { id: "T-ABFM-D5", name: "Risk Identification & Mitigation in Project Finance",   weightage: "High",     dependency: ["T-ABFM-D2"] },
    { id: "T-ABFM-D6", name: "PPP Models — BOT, BOOT, DBFOT, HAM & EPC",              weightage: "Critical", dependency: ["T-ABFM-D1"] },
    { id: "T-ABFM-D7", name: "Infrastructure Financing — Roads, Power & Ports",        weightage: "High",     dependency: ["T-ABFM-D6"] },
    { id: "T-ABFM-D8", name: "Escrow, Waterfall Structures & Trust Mechanisms",        weightage: "High",     dependency: ["T-ABFM-D1"] },
    { id: "T-ABFM-D9", name: "Mezzanine Finance, Subordinated Debt & Quasi-equity",   weightage: "Medium",   dependency: ["T-ABFM-D1"] },
    { id: "T-ABFM-D10", name: "Term Sheet, Conditions Precedent & Loan Documentation", weightage: "Medium",  dependency: ["T-ABFM-D2"] }
  ],

  // ════════════════════════════════════════════════════════
  //  BRBL — Banking Regulations & Business Laws
  // ════════════════════════════════════════════════════════
  "BRBL-A": [
    { id: "T-BRBL-A1",  name: "Banking Regulation Act 1949 — Key Sections",           weightage: "Critical", dependency: [] },
    { id: "T-BRBL-A2",  name: "Reserve Bank of India Act 1934",                       weightage: "Critical", dependency: [] },
    { id: "T-BRBL-A3",  name: "Negotiable Instruments Act 1881 — Bills, Cheques, PNs", weightage: "Critical", dependency: [] },
    { id: "T-BRBL-A4",  name: "Section 138 NI Act — Cheque Dishonour & Penalties",    weightage: "Critical", dependency: ["T-BRBL-A3"] },
    { id: "T-BRBL-A5",  name: "Payment & Settlement Systems Act 2007",                 weightage: "High",     dependency: [] },
    { id: "T-BRBL-A6",  name: "DICGC — Deposit Insurance Coverage & Claims",          weightage: "High",     dependency: [] },
    { id: "T-BRBL-A7",  name: "Prevention of Money Laundering Act (PMLA) 2002",       weightage: "Critical", dependency: [] },
    { id: "T-BRBL-A8",  name: "FEMA 1999 — Key Provisions & Offences",                weightage: "High",     dependency: [] },
    { id: "T-BRBL-A9",  name: "Financial Regulators — Mandate, Jurisdiction & MoU",   weightage: "Medium",   dependency: [] },
    { id: "T-BRBL-A10", name: "Banking Ombudsman Scheme — Awards & Exclusions",        weightage: "High",     dependency: [] }
  ],
  "BRBL-B": [
    { id: "T-BRBL-B1",  name: "Indian Contract Act 1872 — Essentials & Void Contracts", weightage: "Critical", dependency: [] },
    { id: "T-BRBL-B2",  name: "Contract of Guarantee & Indemnity",                    weightage: "Critical", dependency: ["T-BRBL-B1"] },
    { id: "T-BRBL-B3",  name: "Law of Agency — Banker as Agent & Apparent Authority", weightage: "High",     dependency: ["T-BRBL-B1"] },
    { id: "T-BRBL-B4",  name: "Pledge, Hypothecation & Assignment — Legal Distinctions", weightage: "Critical", dependency: [] },
    { id: "T-BRBL-B5",  name: "Law of Mortgage — Types & Banker's Remedies",          weightage: "Critical", dependency: [] },
    { id: "T-BRBL-B6",  name: "Banker's Lien, Right of Set-off & Appropriation",      weightage: "High",     dependency: [] },
    { id: "T-BRBL-B7",  name: "Banker-Customer Relationship — Rights & Duties",       weightage: "Critical", dependency: [] },
    { id: "T-BRBL-B8",  name: "Garnishee Orders, Attachment & Court Orders",          weightage: "High",     dependency: [] },
    { id: "T-BRBL-B9",  name: "Limitation Act 1963 — Banking Applications",           weightage: "High",     dependency: [] },
    { id: "T-BRBL-B10", name: "Nomination Facilities in Bank Accounts",               weightage: "High",     dependency: [] },
    { id: "T-BRBL-B11", name: "Special Account Types — Joint, HUF, Trust, Minor",    weightage: "High",     dependency: [] },
    { id: "T-BRBL-B12", name: "Power of Attorney — Types, Validity & Revocation",    weightage: "Medium",   dependency: [] }
  ],
  "BRBL-C": [
    { id: "T-BRBL-C1",  name: "SARFAESI Act 2002 — Powers, Procedure & Exemptions",   weightage: "Critical", dependency: ["T-BRBL-A1"] },
    { id: "T-BRBL-C2",  name: "Insolvency & Bankruptcy Code 2016 (IBC)",              weightage: "Critical", dependency: [] },
    { id: "T-BRBL-C3",  name: "Recovery of Debts Act (DRT) — Jurisdiction & Process", weightage: "High",     dependency: [] },
    { id: "T-BRBL-C4",  name: "Lok Adalat & MSME Facilitation Council",               weightage: "High",     dependency: [] },
    { id: "T-BRBL-C5",  name: "Credit Information Companies (CICRA 2005) — CIBIL",   weightage: "High",     dependency: [] },
    { id: "T-BRBL-C6",  name: "Bankers' Books Evidence Act 1891",                     weightage: "Medium",   dependency: [] },
    { id: "T-BRBL-C7",  name: "Consumer Protection Act 2019 — Banking Context",       weightage: "High",     dependency: [] },
    { id: "T-BRBL-C8",  name: "Factoring Regulation Act 2011",                        weightage: "Medium",   dependency: [] },
    { id: "T-BRBL-C9",  name: "Warehousing Development & Regulation Act 2007",        weightage: "Medium",   dependency: [] },
    { id: "T-BRBL-C10", name: "Microfinance Regulation & MFI Framework",              weightage: "Medium",   dependency: [] }
  ],
  "BRBL-D": [
    { id: "T-BRBL-D1",  name: "Companies Act 2013 — Key Sections for Bankers",        weightage: "Critical", dependency: [] },
    { id: "T-BRBL-D2",  name: "Types of Companies — Public, Private, OPC, Sec. 8",   weightage: "High",     dependency: ["T-BRBL-D1"] },
    { id: "T-BRBL-D3",  name: "Directors — Duties, Liabilities & Disqualifications",  weightage: "High",     dependency: ["T-BRBL-D1"] },
    { id: "T-BRBL-D4",  name: "Indian Partnership Act 1932 & LLP Act 2008",           weightage: "High",     dependency: [] },
    { id: "T-BRBL-D5",  name: "Sale of Goods Act 1930 — Title, Property & Warranties", weightage: "High",    dependency: [] },
    { id: "T-BRBL-D6",  name: "Information Technology Act 2000 — Cyber Crime for Bankers", weightage: "Critical", dependency: [] },
    { id: "T-BRBL-D7",  name: "Right to Information Act 2005",                        weightage: "Low",      dependency: [] },
    { id: "T-BRBL-D8",  name: "SEBI Regulations — Insider Trading & SAST Takeover Code", weightage: "High",  dependency: [] },
    { id: "T-BRBL-D9",  name: "Insurance Laws & Bancassurance Compliance",            weightage: "Medium",   dependency: [] },
    { id: "T-BRBL-D10", name: "Arbitration & Conciliation Act 1996",                  weightage: "Medium",   dependency: [] },
    { id: "T-BRBL-D11", name: "Stamp Act — Applicability to Banking & Security Documents", weightage: "Medium", dependency: [] }
  ],

  // ════════════════════════════════════════════════════════
  //  Risk Management (Elective)
  // ════════════════════════════════════════════════════════
  "Risk-A": [
    { id: "T-Risk-A1",  name: "Asset Liability Management (ALM) — Concepts & Guidelines", weightage: "Critical", dependency: [] },
    { id: "T-Risk-A2",  name: "Stress Testing & Scenario Analysis",                   weightage: "High",     dependency: [] },
    { id: "T-Risk-A3",  name: "Risk Management Framework — Governance & Taxonomy",    weightage: "High",     dependency: [] },
    { id: "T-Risk-A4",  name: "Enterprise Risk Management (ERM) — COSO & ISO 31000",  weightage: "High",     dependency: ["T-Risk-A3"] },
    { id: "T-Risk-A5",  name: "Risk Appetite Statement, Tolerance & Limit Framework", weightage: "High",     dependency: ["T-Risk-A3"] },
    { id: "T-Risk-A6",  name: "Risk Categories — Financial, Non-financial & Emerging", weightage: "Medium",  dependency: [] },
    { id: "T-Risk-A7",  name: "Risk Culture & Three Lines of Defence Model",          weightage: "High",     dependency: [] },
    { id: "T-Risk-A8",  name: "Integrated Risk Reporting & Board Risk Dashboards",    weightage: "Medium",   dependency: [] }
  ],
  "Risk-B": [
    { id: "T-Risk-B1",  name: "Credit Risk Fundamentals — PD, LGD, EAD, Maturity",   weightage: "Critical", dependency: [] },
    { id: "T-Risk-B2",  name: "Internal Ratings Based (IRB) — F-IRB & A-IRB Approach", weightage: "Critical", dependency: ["T-Risk-B1"] },
    { id: "T-Risk-B3",  name: "Expected Loss (EL), Unexpected Loss (UL) & ECAP",      weightage: "Critical", dependency: ["T-Risk-B1"] },
    { id: "T-Risk-B4",  name: "Credit Portfolio Models — CreditMetrics & KMV",        weightage: "High",     dependency: ["T-Risk-B3"] },
    { id: "T-Risk-B5",  name: "Credit Derivatives — CDS, CDOs & Credit-linked Notes", weightage: "High",     dependency: ["T-Risk-B1"] },
    { id: "T-Risk-B6",  name: "Counterparty Credit Risk (CCR) & Credit Valuation Adjustment (CVA)", weightage: "High", dependency: ["T-Risk-B1"] },
    { id: "T-Risk-B7",  name: "Sectoral & Geographic Credit Concentration Risk",      weightage: "High",     dependency: ["T-Risk-B1"] },
    { id: "T-Risk-B8",  name: "Credit Risk Stress Testing & Reverse Stress Tests",    weightage: "High",     dependency: ["T-Risk-B2"] }
  ],
  "Risk-C": [
    { id: "T-Risk-C1",  name: "VaR Models — Historical, Parametric & Monte Carlo",    weightage: "Critical", dependency: [] },
    { id: "T-Risk-C2",  name: "Expected Shortfall (ES/CVaR) & VaR Backtesting",       weightage: "Critical", dependency: ["T-Risk-C1"] },
    { id: "T-Risk-C3",  name: "Option Sensitivities — Delta, Gamma, Vega, Rho & DV01", weightage: "High",   dependency: [] },
    { id: "T-Risk-C4",  name: "Fundamental Review of Trading Book (FRTB) — SA vs IMA", weightage: "High",   dependency: ["T-Risk-C1"] },
    { id: "T-Risk-C5",  name: "Operational Risk Categories — Basel 7 Loss Event Types", weightage: "Critical", dependency: [] },
    { id: "T-Risk-C6",  name: "Operational Risk Capital — BIA, TSA & IMA Approaches", weightage: "Critical", dependency: ["T-Risk-C5"] },
    { id: "T-Risk-C7",  name: "RCSA, Key Risk Indicators (KRIs) & Loss Data Collection", weightage: "High",  dependency: ["T-Risk-C5"] },
    { id: "T-Risk-C8",  name: "Business Continuity Management (BCM) & Disaster Recovery", weightage: "High", dependency: [] }
  ],
  "Risk-D": [
    { id: "T-Risk-D1",  name: "Risk Governance — Board Risk Committee & CRO Role",    weightage: "High",     dependency: [] },
    { id: "T-Risk-D2",  name: "Risk Policy Framework & Limit Design",                 weightage: "High",     dependency: ["T-Risk-D1"] },
    { id: "T-Risk-D3",  name: "RAROC, Economic Profit & Risk-Adjusted Performance",   weightage: "Critical", dependency: [] },
    { id: "T-Risk-D4",  name: "Economic Capital vs. Regulatory Capital — Allocation", weightage: "Critical", dependency: ["T-Risk-D3"] },
    { id: "T-Risk-D5",  name: "Pillar 2 — ICAAP Process & SREP Interaction",          weightage: "Critical", dependency: [] },
    { id: "T-Risk-D6",  name: "Recovery & Resolution Planning — Living Wills & BREP", weightage: "High",     dependency: [] },
    { id: "T-Risk-D7",  name: "Systemic Risk — D-SIBs, G-SIBs & Macroprudential Policy", weightage: "High", dependency: [] },
    { id: "T-Risk-D8",  name: "Regulatory Risk Reporting — Basel Disclosures & Pillar 3", weightage: "Medium", dependency: [] }
  ],

  // ════════════════════════════════════════════════════════
  //  IT & Digital Banking (Elective)
  // ════════════════════════════════════════════════════════
  "IT-A": [
    { id: "T-IT-A1",  name: "IT in Banking — Evolution, CBS & Digital Transformation",  weightage: "Medium",  dependency: [] },
    { id: "T-IT-A2",  name: "Core Banking Solution (CBS) — Architecture & Modules",     weightage: "High",    dependency: [] },
    { id: "T-IT-A3",  name: "Data Centres, Cloud Computing & Virtualisation in Banks",  weightage: "Medium",  dependency: [] },
    { id: "T-IT-A4",  name: "IT Governance — COBIT Framework & IT Audit",               weightage: "High",    dependency: [] },
    { id: "T-IT-A5",  name: "IT Risk Management & Technology Risk Framework",           weightage: "High",    dependency: [] },
    { id: "T-IT-A6",  name: "Digital Banking — Internet, Mobile & Omni-channel",        weightage: "High",    dependency: [] }
  ],
  "IT-B": [
    { id: "T-IT-B1",  name: "Payment Systems — RTGS, NEFT, IMPS, UPI & Bharat Bill Pay", weightage: "Critical", dependency: [] },
    { id: "T-IT-B2",  name: "Card Payment Systems — Debit, Credit & Prepaid Cards",     weightage: "High",    dependency: [] },
    { id: "T-IT-B3",  name: "Blockchain & Distributed Ledger Technology (DLT)",         weightage: "Medium",  dependency: [] },
    { id: "T-IT-B4",  name: "Regulatory Framework — RBI IT Guidelines & Cyber Security Directions", weightage: "Critical", dependency: [] },
    { id: "T-IT-B5",  name: "Fintech, Open Banking & API Ecosystem",                    weightage: "High",    dependency: [] },
    { id: "T-IT-B6",  name: "Artificial Intelligence & ML in Banking",                  weightage: "Medium",  dependency: [] }
  ],
  "IT-C": [
    { id: "T-IT-C1",  name: "Cyber Incident Reporting & Response — RBI Framework",      weightage: "Critical", dependency: [] },
    { id: "T-IT-C2",  name: "Core Banking Security Architectures & Access Controls",    weightage: "Critical", dependency: [] },
    { id: "T-IT-C3",  name: "Network Security — Firewalls, IDS/IPS & Encryption",      weightage: "High",    dependency: [] },
    { id: "T-IT-C4",  name: "Cyber Fraud Types — Phishing, Vishing, Malware, Ransomware", weightage: "Critical", dependency: [] },
    { id: "T-IT-C5",  name: "Data Protection — PDPB, GDPR Basics & Data Localisation",  weightage: "High",    dependency: [] },
    { id: "T-IT-C6",  name: "SOC, SIEM & Security Monitoring in Banks",                 weightage: "Medium",  dependency: [] }
  ],
  "IT-D": [
    { id: "T-IT-D1",  name: "Big Data Analytics & Data Warehousing in Banking",         weightage: "Medium",  dependency: [] },
    { id: "T-IT-D2",  name: "Customer Analytics — Segmentation, Churn & CLV",           weightage: "Medium",  dependency: [] },
    { id: "T-IT-D3",  name: "Regtech, Suptech & Regulatory Reporting Automation",       weightage: "Medium",  dependency: [] },
    { id: "T-IT-D4",  name: "Digital Lending, Account Aggregator & ONDC",               weightage: "High",    dependency: [] },
    { id: "T-IT-D5",  name: "Central Bank Digital Currency (CBDC) & e-Rupee",           weightage: "High",    dependency: [] }
  ],

  // ════════════════════════════════════════════════════════
  //  HR Management (Elective)
  // ════════════════════════════════════════════════════════
  "HR-A": [
    { id: "T-HR-A1",  name: "HRM — Evolution, Scope & Strategic HRM",                  weightage: "Medium",  dependency: [] },
    { id: "T-HR-A2",  name: "HR Planning, Forecasting & Talent Pipeline",              weightage: "Medium",  dependency: [] },
    { id: "T-HR-A3",  name: "Job Analysis, Job Description & Person Specification",    weightage: "Low",     dependency: [] },
    { id: "T-HR-A4",  name: "Recruitment, Selection & Assessment Methods",             weightage: "Medium",  dependency: [] },
    { id: "T-HR-A5",  name: "Induction, Probation & Placement in Banks",               weightage: "Low",     dependency: [] },
    { id: "T-HR-A6",  name: "Employee Engagement, Retention & Attrition Management",   weightage: "Medium",  dependency: [] }
  ],
  "HR-B": [
    { id: "T-HR-B1",  name: "Training Methods — On-job, Off-job, CBT, e-Learning",     weightage: "Medium",  dependency: [] },
    { id: "T-HR-B2",  name: "Training Need Analysis (TNA) & Training Design",          weightage: "Medium",  dependency: [] },
    { id: "T-HR-B3",  name: "Training Evaluation — Kirkpatrick & ROI of Training",     weightage: "High",    dependency: ["T-HR-B2"] },
    { id: "T-HR-B4",  name: "Career Planning, Succession Planning & Talent Mgmt",      weightage: "Medium",  dependency: [] },
    { id: "T-HR-B5",  name: "Mentoring, Coaching & Executive Development",             weightage: "Low",     dependency: [] },
    { id: "T-HR-B6",  name: "Knowledge Management & Learning Organisations",           weightage: "Low",     dependency: [] }
  ],
  "HR-C": [
    { id: "HR-C1",    name: "Performance Management Systems (PMS) — ACR to BSC",       weightage: "High",    dependency: [] },
    { id: "HR-C2",    name: "Compensation Structure, CTC & Stock Options (ESOPs)",      weightage: "High",    dependency: [] },
    { id: "T-HR-C3",  name: "Pay Revision in PSBs — Bipartite Settlements & IBA",      weightage: "High",    dependency: [] },
    { id: "T-HR-C4",  name: "Employee Benefits — PF, Gratuity, Pension & Leave",       weightage: "High",    dependency: [] },
    { id: "T-HR-C5",  name: "360-Degree Feedback, MBO & Performance Calibration",      weightage: "Medium",  dependency: ["HR-C1"] },
    { id: "T-HR-C6",  name: "Reward Management — Incentives, Recognition & ESOPs",     weightage: "Medium",  dependency: [] }
  ],
  "HR-D": [
    { id: "T-HR-D1",  name: "Industrial Relations — Concept, Actors & IR Climate",     weightage: "High",    dependency: [] },
    { id: "T-HR-D2",  name: "Trade Unions — Registration, Rights & Recognition",       weightage: "High",    dependency: ["T-HR-D1"] },
    { id: "T-HR-D3",  name: "Industrial Disputes Act 1947 — Disputes & Adjudication",  weightage: "Critical", dependency: ["T-HR-D2"] },
    { id: "T-HR-D4",  name: "Collective Bargaining, Conciliation & Arbitration",       weightage: "High",    dependency: ["T-HR-D3"] },
    { id: "T-HR-D5",  name: "Grievance Handling Procedure & Domestic Enquiry",         weightage: "High",    dependency: [] },
    { id: "T-HR-D6",  name: "Disciplinary Action — Principles of Natural Justice",     weightage: "Critical", dependency: ["T-HR-D5"] },
    { id: "T-HR-D7",  name: "Standing Orders & Service Rules in Banks",                weightage: "High",    dependency: [] },
    { id: "T-HR-D8",  name: "Labour Codes 2019-20 — Wage Code & Social Security Code",  weightage: "High",    dependency: [] },
    { id: "T-HR-D9",  name: "Industrial Relations Code 2020 — Key Provisions & Impact",  weightage: "High",    dependency: ["T-HR-D1"] }
  ],

  // ════════════════════════════════════════════════════════
  //  Rural Banking (Elective)
  // ════════════════════════════════════════════════════════
  "Rural-A": [
    { id: "T-Rural-A1", name: "Rural India — Socio-economic Profile & Demographics",   weightage: "Medium",  dependency: [] },
    { id: "T-Rural-A2", name: "Indian Agricultural Sector — Structure & Challenges",   weightage: "High",    dependency: [] },
    { id: "T-Rural-A3", name: "Rural Credit Markets — Formal vs. Informal Sources",    weightage: "High",    dependency: [] },
    { id: "T-Rural-A4", name: "Rural Infrastructure — Roads, Power, Water & Digital",  weightage: "Low",     dependency: [] },
    { id: "T-Rural-A5", name: "NABARD — Role, Functions & Refinance Programmes",       weightage: "Critical", dependency: [] },
    { id: "T-Rural-A6", name: "Regional Rural Banks (RRBs) — Structure & Performance", weightage: "High",    dependency: [] }
  ],
  "Rural-B": [
    { id: "T-Rural-B1", name: "Agricultural Finance — Crop Loans, KCC & Scale of Finance", weightage: "Critical", dependency: [] },
    { id: "T-Rural-B2", name: "Land Development & Farm Mechanisation Finance",          weightage: "High",    dependency: [] },
    { id: "T-Rural-B3", name: "SHG-Bank Linkage Programme & Microfinance",             weightage: "Critical", dependency: [] },
    { id: "T-Rural-B4", name: "Warehousing, Pledge Finance & Commodity Loans",         weightage: "High",    dependency: [] },
    { id: "T-Rural-B5", name: "Rural Housing Finance & PMAY-G",                        weightage: "Medium",  dependency: [] },
    { id: "T-Rural-B6", name: "MSME & Allied Activities in Rural Areas",               weightage: "Medium",  dependency: [] },
    { id: "T-Rural-B7", name: "PMMSY, Fisheries Finance & Animal Husbandry KCC",      weightage: "High",    dependency: ["T-Rural-B1"] }
  ],
  "Rural-C": [
    { id: "T-Rural-C1", name: "Priority Sector Lending — Targets, Sub-targets & Reporting", weightage: "Critical", dependency: [] },
    { id: "T-Rural-C2", name: "Government Rural Schemes — PM-KISAN, MGNREGS, PMJDY",  weightage: "High",    dependency: [] },
    { id: "T-Rural-C3", name: "RIDF & Shortfall in PSL — NABARD & SIDBI Contributions", weightage: "High",   dependency: ["T-Rural-C1"] },
    { id: "T-Rural-C4", name: "Financial Inclusion — BC Model, Jan Dhan & DBT",        weightage: "Critical", dependency: [] },
    { id: "T-Rural-C5", name: "Insurance for Agriculture — PMFBY & Weather-based Crop Insurance", weightage: "High", dependency: [] },
    { id: "T-Rural-C6", name: "Interest Subvention Scheme on Agricultural Loans",      weightage: "High",    dependency: ["T-Rural-B1"] }
  ],
  "Rural-D": [
    { id: "T-Rural-D1", name: "Challenges in Agricultural Lending — NPA & Recovery",   weightage: "High",    dependency: [] },
    { id: "T-Rural-D2", name: "Digital Financial Services in Rural Banking",            weightage: "High",    dependency: [] },
    { id: "T-Rural-D3", name: "Cooperative Banks & PACS — Structure & Reforms",        weightage: "Medium",  dependency: [] },
    { id: "T-Rural-D4", name: "Agri Value Chain Finance & Warehouse Receipt System",   weightage: "Medium",  dependency: [] },
    { id: "T-Rural-D5", name: "Rural Development Schemes — PMEGP, MUDRA & PM SVANidhi", weightage: "High",  dependency: [] }
  ],

  // ════════════════════════════════════════════════════════
  //  Central Banking (Elective)
  // ════════════════════════════════════════════════════════
  "Central-A": [
    { id: "T-Central-A1", name: "Rationale & Functions of a Central Bank",             weightage: "Medium",  dependency: [] },
    { id: "T-Central-A2", name: "History & Evolution of RBI (1935 onwards)",           weightage: "Low",     dependency: [] },
    { id: "T-Central-A3", name: "Objectives of Monetary Policy — Price Stability & Growth", weightage: "High", dependency: [] },
    { id: "T-Central-A4", name: "Currency Issuance — Minimum Reserve System & Notes", weightage: "Medium",  dependency: [] },
    { id: "T-Central-A5", name: "Banker's Bank & Lender of Last Resort (LOLR)",        weightage: "High",    dependency: [] },
    { id: "T-Central-A6", name: "Government's Banker — Debt Mgmt, WAM & PDMA",        weightage: "Medium",  dependency: [] }
  ],
  "Central-B": [
    { id: "T-Central-B1", name: "RBI Organisational Structure & Departments",          weightage: "Low",     dependency: [] },
    { id: "T-Central-B2", name: "Monetary Policy Committee (MPC) — Composition & Mandate", weightage: "Critical", dependency: [] },
    { id: "T-Central-B3", name: "RBI as Regulator — Licensing, Supervision & Inspection", weightage: "High",  dependency: [] },
    { id: "T-Central-B4", name: "Financial Stability & Macroprudential Framework",    weightage: "High",    dependency: [] },
    { id: "T-Central-B5", name: "Payment System Regulation & DPSS",                   weightage: "High",    dependency: [] },
    { id: "T-Central-B6", name: "Consumer Protection & Banking Ombudsman (RBI's Role)", weightage: "Medium", dependency: [] }
  ],
  "Central-C": [
    { id: "T-Central-C1", name: "Monetary Policy Instruments — CRR, SLR, Repo, MSF",  weightage: "Critical", dependency: [] },
    { id: "T-Central-C2", name: "Liquidity Adjustment Facility (LAF) — Corridor & Operations", weightage: "Critical", dependency: ["T-Central-C1"] },
    { id: "T-Central-C3", name: "Open Market Operations (OMO) & G-SAP",               weightage: "High",    dependency: ["T-Central-C2"] },
    { id: "T-Central-C4", name: "Flexible Inflation Targeting (FIT) Framework",        weightage: "Critical", dependency: [] },
    { id: "T-Central-C5", name: "Credit Policy — Priority Sector & Sectoral Directives", weightage: "High",  dependency: [] },
    { id: "T-Central-C6", name: "Transmission Mechanism of Monetary Policy",           weightage: "High",    dependency: ["T-Central-C1"] }
  ],
  "Central-D": [
    { id: "T-Central-D1", name: "Foreign Exchange Reserves — Composition & Management", weightage: "High",   dependency: [] },
    { id: "T-Central-D2", name: "RBI's Forex Intervention — Tools & Rationale",         weightage: "High",   dependency: ["T-Central-D1"] },
    { id: "T-Central-D3", name: "External Commercial Borrowings (ECB) Policy",          weightage: "High",   dependency: [] },
    { id: "T-Central-D4", name: "Capital Account Convertibility — Current Status",      weightage: "Medium", dependency: [] },
    { id: "T-Central-D5", name: "SDRs, IMF Quota & India's International Commitments", weightage: "Medium",  dependency: [] },
    { id: "T-Central-D6", name: "GIFT City / IFSC — Structure, Regulators & Banking",  weightage: "High",    dependency: [] }
  ],
  "Central-E": [
    { id: "T-Central-E1", name: "Risk-Based Supervision (RBS) Framework",              weightage: "Critical", dependency: [] },
    { id: "T-Central-E2", name: "Prompt Corrective Action (PCA) — Triggers & Restrictions", weightage: "Critical", dependency: [] },
    { id: "T-Central-E3", name: "Basel III Implementation in India — RBI Roadmap",     weightage: "High",    dependency: [] },
    { id: "T-Central-E4", name: "Bank Licensing — Universal, Differentiated & SFBs",  weightage: "High",    dependency: [] },
    { id: "T-Central-E5", name: "Annual Inspection & CAMEL Rating Methodology",        weightage: "Medium",  dependency: [] }
  ],
  "Central-F": [
    { id: "T-Central-F1", name: "NBFCs — Categories, Regulation & Scale-based Framework", weightage: "Critical", dependency: [] },
    { id: "T-Central-F2", name: "Primary Dealers (PDs) — Role in G-Sec Markets",       weightage: "High",    dependency: [] },
    { id: "T-Central-F3", name: "Systemically Important NBFCs (NBFC-ND-SI) — Prudential Norms", weightage: "High", dependency: ["T-Central-F1"] },
    { id: "T-Central-F4", name: "Housing Finance Companies (HFCs) — NHB & RBI Overlap", weightage: "Medium", dependency: [] }
  ]

};


export const FORMULAS = [
  // BFM
  { id: "F-BFM1", sub: "BFM", tag: "Basel III", name: "Capital Adequacy Ratio (CRAR)", f: "(Tier I Capital + Tier II Capital) / RWA × 100", note: "Regulatory Min: 9% (RBI) | 8% (Basel III Accord). Must be supported by CET1 of at least 5.5%." },
  { id: "F-BFM2", sub: "BFM", tag: "Liquidity", name: "Liquidity Coverage Ratio (LCR)", f: "HQLA / Net Cash Outflows over 30 days × 100", note: "Min 100%. Ensures a bank holds liquid assets to survive a severe 30-day liquidity stress event." },
  { id: "F-BFM3", sub: "BFM", tag: "Liquidity", name: "Net Stable Funding Ratio (NSFR)", f: "Available Stable Funding (ASF) / Required Stable Funding (RSF) × 100", note: "Min 100%. Structural, 1-year liquidity horizon check." },
  { id: "F-BFM4", sub: "BFM", tag: "Bonds", name: "Modified Duration (MD)", f: "Macaulay Duration / (1 + YTM / n)", note: "Measures percentage change in bond price for a 1% change in yield. Direct price sensitivity index." },
  { id: "F-BFM5", sub: "BFM", tag: "Risk", name: "Value at Risk (VaR)", f: "Mean Return (μ) − (z-score × Standard Deviation (σ)) × √t", note: "Common z-scores: 1.65 (90% confidence), 1.96 (95% confidence), 2.33 (99% confidence)." },
  // ABM
  { id: "F-ABM1", sub: "ABM", tag: "Credit", name: "Debt Service Coverage Ratio (DSCR)", f: "(Net Profit + Depreciation + Interest on Long-Term Debt) / (Installments + Interest on Long-Term Debt)", note: "Indicates capacity to service debt. Ideal benchmark is 1.25x to 1.5x in project lending." },
  { id: "F-ABM2", sub: "ABM", tag: "Credit", name: "Tandon MPBF Method I", f: "0.75 × (Current Assets − Current Liabilities excluding Bank Borrowings)", note: "Borrower brings in 25% of working capital gap as Net Working Capital (NWC)." },
  { id: "F-ABM3", sub: "ABM", tag: "Credit", name: "Tandon MPBF Method II", f: "(0.75 × Current Assets) − Current Liabilities excluding Bank Borrowings", note: "Borrower funds 25% of Current Assets as margin from long term sources." },
  // ABFM
  { id: "F-ABFM1", sub: "ABFM", tag: "Valuation", name: "CAPM Cost of Equity", f: "Rf + Beta (β) × (Rm − Rf)", note: "Rf = Risk-free rate, Rm = Market rate, (Rm - Rf) = Equity/Market Risk Premium." },
  { id: "F-ABFM2", sub: "ABFM", tag: "Valuation", name: "Net Present Value (NPV)", f: "Σ [ Cash Flow_t / (1 + r)^t ] − Initial Investment", note: "Accept project if NPV > 0. Discounting factor r is typically the WACC." },
  { id: "F-ABFM3", sub: "ABFM", tag: "Valuation", name: "Weighted Average Cost of Capital (WACC)", f: "(E/V × Ke) + (D/V × Kd × (1 − T))", note: "Ke = Cost of equity, Kd = Cost of debt, T = tax rate, E = Equity value, D = Debt value, V = E+D." },
  // Additional ABM credit & economics formulas
  { id: "F-ABM4", sub: "ABM", tag: "Credit", name: "Nayak Committee Working Capital (Turnover Method)", f: "Bank WC Limit = 20% of Projected Annual Turnover | Borrower Margin = 5% of Turnover", note: "Applicable for MSME credit limits up to ₹7.5 Crore (revised 2026). Simple method — no detailed CMA data required." },
  { id: "F-ABM5", sub: "ABM", tag: "NPA", name: "Gross NPA Ratio", f: "(Gross NPA / Gross Advances) × 100", note: "Key asset quality indicator. <5%: healthy | 5–10%: moderate stress | >10%: poor. Watched by RBI, investors, and rating agencies." },
  { id: "F-ABM6", sub: "ABM", tag: "NPA", name: "Net NPA Ratio", f: "(Gross NPA − Provisions Held) / (Gross Advances − Provisions Held) × 100", note: "Reflects true uncovered NPA exposure net of provisions. Lower Net NPA = stronger provision coverage." },
  { id: "F-ABM7", sub: "ABM", tag: "NPA", name: "Provision Coverage Ratio (PCR)", f: "(Cumulative Provisions on NPA / Gross NPA) × 100", note: "RBI desirable PCR: ≥ 70%. Higher PCR means the bank is better cushioned against actual credit losses." },
  { id: "F-ABM8", sub: "ABM", tag: "Credit", name: "Current Ratio", f: "Current Assets / Current Liabilities", note: "Working capital health. RBI benchmark for fund-based WC limit sanction: ≥ 1.33 (i.e., NWC ≥ 25% of Current Assets)." },
  { id: "F-ABM9", sub: "ABM", tag: "Credit", name: "Debt-Equity Ratio (Leverage)", f: "Total Long-Term Debt / Tangible Net Worth (Equity)", note: "Acceptable range: ≤ 2:1 for manufacturing; infrastructure may permit up to 3:1. Higher ratio = higher financial leverage risk." },
  { id: "F-ABM10", sub: "ABM", tag: "Credit", name: "Interest Coverage Ratio (ICR / TIE)", f: "EBIT / Annual Interest Expense", note: "Measures ability to service interest from operating profit. Minimum acceptable: ≥ 1.5x; preferred for term loans: ≥ 2.5x." },
  { id: "F-ABM11", sub: "ABM", tag: "Economics", name: "Real GDP (Deflated)", f: "Real GDP = Nominal GDP / (GDP Deflator / 100)", note: "Removes price level distortion. Real GDP growth is the true measure of economic expansion used in monetary policy formulation." },
  { id: "F-ABM12", sub: "ABM", tag: "Economics", name: "Fiscal Deficit & Primary Deficit", f: "Fiscal Deficit = Total Expenditure − (Revenue Receipts + Non-Debt Capital Receipts) | Primary Deficit = Fiscal Deficit − Interest Payments", note: "FRBM 2003 target: Fiscal Deficit ≤ 3% of GDP. Primary Deficit → Zero is the ideal for long-run debt sustainability." },
  // ABM — additional formulas
  { id: "F-ABM13", sub: "ABM", tag: "Credit", name: "EMI (Equated Monthly Instalment)", f: "EMI = P × r × (1+r)^n / [(1+r)^n − 1]", note: "P = Principal, r = monthly rate (annual rate ÷ 12), n = number of monthly instalments. Constant throughout tenure." },
  { id: "F-ABM14", sub: "ABM", tag: "Profitability", name: "Net Interest Margin (NIM)", f: "(Interest Income − Interest Expense) / Average Earning Assets × 100", note: "Key bank profitability ratio. Indian benchmark: 2.5–3.5% PSBs; 4–5% private banks. NIM compression risk when deposit rates rise faster than lending rates." },
  { id: "F-ABM15", sub: "ABM", tag: "Profitability", name: "Return on Assets (ROA)", f: "Net Profit After Tax / Average Total Assets × 100", note: "RBI benchmark: ≥0.5% healthy; ≥1% well-managed. ROE = ROA × Financial Leverage (Total Assets / Equity) — DuPont relationship." },
  { id: "F-ABM16", sub: "ABM", tag: "Profitability", name: "Return on Equity (ROE) — DuPont", f: "ROE = Net Profit / Avg Equity = (Profit Margin) × (Asset Turnover) × (Financial Leverage)", note: "ROE = ROA × (Assets/Equity). For banks, primarily driven by leverage and NIM. Higher equity (capital infusion) dilutes ROE unless profitability rises proportionally." },
  { id: "F-ABM17", sub: "ABM", tag: "Economics", name: "Money Multiplier (Credit Multiplier)", f: "Simple: MM = 1 / CRR | Practical: MM = (1+c) / (c+r+e) where c=cash-deposit ratio, r=reserve ratio, e=excess reserves", note: "At CRR=4%, simple multiplier = 25. Actual multiplier lower due to cash leakage & excess reserves. RBI raises CRR → lower MM → contracts money supply." },
  { id: "F-ABM18", sub: "ABM", tag: "Credit", name: "Weighted Average Cost of Deposits", f: "Σ(Deposit Amount_i × Rate_i) / Total Deposits × 100", note: "Key input for MCLR calculation. Lower cost of funds → lower MCLR → competitive lending rates. Cost decomposition: CASA (low cost) + Term Deposits (higher cost)." },
  { id: "F-ABM19", sub: "ABM", tag: "Economics", name: "Current Account Deficit (CAD)", f: "CAD = Trade Deficit + Services Balance + Income Balance + Transfer Balance | Sustainable: ≤ 2.5% of GDP", note: "Wide CAD → rupee depreciation → imported inflation → RBI tightens. India's CAD: typically 1.5–2.5% of GDP. Financed by FPI, FDI, ECB inflows." },
  { id: "F-ABM20", sub: "ABM", tag: "Credit", name: "Leverage Ratio (Basel III / RBI)", f: "Tier 1 Capital / Total Exposure (on+off balance sheet) × 100 ≥ 3.5% (RBI minimum)", note: "Non-risk-based backstop to CRAR. Prevents excessive balance sheet leverage regardless of risk weights. RBI minimum 3.5%; D-SIBs may face higher surcharge." },
  // BFM — additional formulas
  { id: "F-BFM6", sub: "BFM", tag: "Bonds", name: "Bond Pricing (DCF Model)", f: "Bond Price = Σ[C/(1+y)^t] + FV/(1+y)^n | C=coupon, y=YTM per period, n=periods, FV=face value", note: "Dirty Price = Clean Price + Accrued Interest. Discount if y>coupon; Premium if y<coupon; Par if y=coupon. Inverse price-yield relationship." },
  { id: "F-BFM7", sub: "BFM", tag: "Bonds", name: "Macaulay Duration", f: "D_mac = Σ[t × PV(CF_t)] / Bond Price | PV(CF_t) = CF_t / (1+y)^t", note: "Weighted-average maturity of bond's cash flows. Zero-coupon bond: D_mac = Maturity. Coupon bond: D_mac < Maturity. Units: years." },
  { id: "F-BFM8", sub: "BFM", tag: "Bonds", name: "DV01 / PVBP (Price Value of Basis Point)", f: "DV01 = Modified Duration × Bond Price × 0.0001 | Or: [P(y−1bp) − P(y+1bp)] / 2", note: "Rupee change in bond value for 1 bp yield change. Used by treasury for position sizing and hedge ratio calculation. DV01 × 10,000 = approximate % price change for 1% yield." },
  { id: "F-BFM9", sub: "BFM", tag: "Bonds", name: "YTM Interpolation (Trial & Error)", f: "YTM = r_low + [(P_low − P_target)/(P_low − P_high)] × (r_high − r_low)", note: "P_low = price at lower trial rate; P_high = price at higher rate. If price < FV → YTM > coupon → start trials above coupon rate. Exam pattern: price given → find YTM." },
  { id: "F-BFM10", sub: "BFM", tag: "ALM", name: "NII Sensitivity (Rate-Sensitive Gap)", f: "ΔNII = GAP × Δr | GAP = RSA − RSL | RSA = Rate-Sensitive Assets, RSL = Rate-Sensitive Liabilities", note: "Positive GAP (RSA>RSL): NII rises when rates rise. Negative GAP (RSL>RSA): NII falls when rates rise. Traditional gap analysis; supplements with duration-based EVE analysis." },
  { id: "F-BFM11", sub: "BFM", tag: "ALM", name: "Economic Value of Equity (EVE) Sensitivity", f: "ΔEVE ≈ −MD_Assets × Asset_MV × Δy + MD_Liabilities × Liab_MV × Δy", note: "Captures long-term interest rate risk to net worth. RBI IRRBB: EVE decline >15% of Tier 1 under ±200bps = outlier bank. Complements short-term NII analysis." },
  { id: "F-BFM12", sub: "BFM", tag: "Forex", name: "Forward Exchange Rate (Interest Rate Parity)", f: "F = S × (1+r_d)^t / (1+r_f)^t | Approximate: F ≈ S × [1 + (r_d−r_f)×t]", note: "F=forward, S=spot, r_d=domestic rate, r_f=foreign rate. Forward Premium % = [(F−S)/S] × (12/months) × 100. If r_d > r_f: domestic currency at forward discount." },
  { id: "F-BFM13", sub: "BFM", tag: "Forex", name: "Cross Currency Rate", f: "EUR/INR = (USD/INR) / (USD/EUR) | Example: USD/INR=84, USD/EUR=1.09 → EUR/INR = 84/1.09 = 77.06", note: "Cross rate = rate between two non-dollar currencies derived through USD intermediary. For bid/ask: use buy side of intermediary pair for buy side of cross." },
  { id: "F-BFM14", sub: "BFM", tag: "Forex", name: "Forex Swap Points / Forward Premium", f: "Swap Points = Forward Rate − Spot Rate | Premium % = [(F−S)/S] × (12/months) × 100", note: "Positive swap points = domestic currency at premium (domestic rates < foreign). Negative = discount (domestic rates > foreign). Reflects covered interest rate differential." },
  // ABFM — additional formulas
  { id: "F-ABFM4", sub: "ABFM", tag: "Valuation", name: "Gordon's Dividend Growth Model (DDM)", f: "P₀ = D₁ / (Ke − g) | D₁ = D₀ × (1+g) | g = Retention Ratio × ROE", note: "P₀=current price; D₁=next year dividend; Ke=required return (from CAPM); g=sustainable growth. Condition: Ke > g. Used for stable dividend-paying bank stocks." },
  { id: "F-ABFM5", sub: "ABFM", tag: "Valuation", name: "P/E and P/B Ratios", f: "P/E = Market Price / EPS | P/B = Market Price / Book Value per Share | EPS = Net Profit / Number of Shares", note: "P/B preferred for banks (asset-heavy). Book value = Equity (Net Worth) / Shares. P/B < 1 = bank trading below book value (stressed). Banks at P/B 1.5-2.5 considered fairly valued." },
  { id: "F-ABFM6", sub: "ABFM", tag: "Valuation", name: "IRR Interpolation", f: "IRR = r₁ + [NPV₁ / (NPV₁ − NPV₂)] × (r₂ − r₁) | Accept if IRR > WACC (hurdle rate)", note: "r₁ = rate where NPV > 0, r₂ = rate where NPV < 0. Same interpolation principle as YTM. NPV and IRR may conflict for mutually exclusive projects → use NPV." },
  { id: "F-ABFM7", sub: "ABFM", tag: "Valuation", name: "Payback Period (PBP)", f: "PBP = Initial Investment / Annual CF (uniform) | Or: cumulative CF until equals initial investment (uneven flows)", note: "Simple, ignores TVM. Banks use PBP for rough feasibility; NPV/IRR for actual decision. Discounted Payback Period = PBP using PV of cash flows. Shorter PBP preferred." },
  { id: "F-ABFM8", sub: "ABFM", tag: "Valuation", name: "Break-Even Point (BEP)", f: "BEP (units) = Fixed Costs / Contribution per unit | BEP (₹) = Fixed Costs / P/V Ratio | P/V Ratio = Contribution / Sales", note: "Used in project appraisal to identify minimum revenue needed. Margin of Safety = (Actual Sales − BEP Sales) / Actual Sales × 100. Higher MoS = more cushion." },
  { id: "F-ABFM9", sub: "ABFM", tag: "Valuation", name: "NAV of Mutual Fund", f: "NAV = (Portfolio Market Value + Receivables − Liabilities) / Units Outstanding", note: "Declared daily by SEBI-registered AMCs. Entry load abolished 2009; exit load typically 0-1%. NAV growth = fund performance. Total return = (NAV change + Dividends) / Initial NAV." },
  // BRBL — key statutory thresholds and timelines (formatted as formulas for exam reference)
  { id: "F-BRBL1", sub: "BRBL", tag: "SARFAESI", name: "SARFAESI Act — Key Timelines", f: "Demand Notice: 60 days | Borrower objection: within 15 days | Reply to objection: 15 days | Residential property DM order: 30 days | Minimum NPA: ₹1 lakh", note: "Applicable only to secured debts (not agricultural land). CERSAI registration mandatory for all charges. Symbol: creditor holds security interest — enforcement without court order. RDB/IBC: parallel remedies." },
  { id: "F-BRBL2", sub: "BRBL", tag: "Recovery", name: "DRT / RDDBFI — Thresholds & Limitation", f: "DRT jurisdiction: ≥ ₹20 lakh | Limitation: 3 years (Limitation Act 1963) | DRAT appeal: within 45 days of DRT order + 75% deposit | Filing fee: schedule-based", note: "DRT has exclusive jurisdiction over bank/FI claims above ₹20L. Recovery Officer issues Recovery Certificate. DRAT order appealable to High Court. Banks file with original cause of action — acknowledge debt letters reset limitation period." },
  { id: "F-BRBL3", sub: "BRBL", tag: "IBC", name: "IBC 2016 — CIRP Key Numbers", f: "CIRP: 180 days (extendable +90 days) | Max with NCLT extension: 330 days | NCLT admission: 14 days | Minimum default threshold: ₹1 crore | PPIRP (MSME): 120 days", note: "Financial Creditors, Operational Creditors, or Corporate Debtor itself can trigger CIRP. CoC: financial creditors only. Resolution Professional (RP) manages company during CIRP. Liquidation waterfall: Sec 53 IBC." },
  { id: "F-BRBL4", sub: "BRBL", tag: "FEMA", name: "FEMA — Penalty and Compounding", f: "Penalty: up to 3× amount involved OR ₹2 lakh (whichever higher) | Compounding: up to 300% of contravention amount | Adjudication: ED (serious) / RBI (routine)", note: "FEMA violations: civil not criminal (except money laundering). Compounding available for most violations — self-declaration to AD bank/RBI. Voluntary FEMA disclosure encouraged to avoid penal proceedings." },
  { id: "F-BRBL5", sub: "BRBL", tag: "NI Act", name: "Cheque Dishonour — Sec 138 NI Act", f: "Cheque validity: 3 months | Notice: within 30 days of dishonour | Drawer's time to pay: 15 days | Complaint: within 30 days of expiry of 15-day period", note: "Sec 138 offence: imprisonment ≤2 years + fine ≤2× cheque amount (or both). Multiple cheques from same drawer: separate Sec 138 complaints for each. Sec 147 allows compounding. Lok Adalat: 75% cheque value as settlement norm." },
  { id: "F-BRBL6", sub: "BRBL", tag: "Consumer Protection", name: "Integrated Ombudsman Scheme 2021 — Award Limits", f: "Max award: ₹20 lakh (pecuniary) + ₹1 lakh (non-pecuniary) | Complaint time limit: 1 year from bank's final response | No complaint fee | Portal: cms.rbi.org.in", note: "IOS 2021 merged Banking + NBFC + Digital Payments Ombudsman schemes into one. 'Submit and Forget' — RBI routes to right authority. Appeal to RBI Appellate Authority (Deputy Governor) within 30 days of award." },
  // Risk Management
  { id: "F-Risk1", sub: "Risk", tag: "Credit Risk", name: "Expected Loss (EL)", f: "EL = PD × LGD × EAD | PD: Probability of Default | LGD: Loss Given Default (%) | EAD: Exposure at Default (₹)", note: "Foundation of IRB credit risk capital under Basel II/III. EL is covered by provisions; Unexpected Loss (UL) is covered by capital. Bank pricing: loan rate must cover EL + funding cost + operating cost + UL capital cost." },
  { id: "F-Risk2", sub: "Risk", tag: "Credit Risk", name: "RAROC (Risk-Adjusted Return on Capital)", f: "RAROC = (NII + Fees − Operating Cost − Expected Loss) / Economic Capital × 100 | Target: ≥ Cost of Equity", note: "Economic Capital = UL at 99.9% confidence − EL. RAROC > hurdle rate (cost of equity ~12-15%) = value-creating loan/portfolio. Used in relationship pricing, business line performance measurement." },
  { id: "F-Risk3", sub: "Risk", tag: "Market Risk", name: "Sharpe Ratio (Risk-Adjusted Return)", f: "Sharpe Ratio = (Rp − Rf) / σp | Rp=portfolio return, Rf=risk-free rate, σp=std dev of portfolio return", note: "Higher Sharpe = better risk-adjusted return per unit of total risk. Treynor Ratio = (Rp−Rf)/β (uses systematic risk). Jensen's Alpha = Rp − [Rf + β(Rm−Rf)] (excess above CAPM expected return)." },
  { id: "F-Risk4", sub: "Risk", tag: "Market Risk", name: "Beta (Systematic Risk)", f: "β = Cov(R_asset, R_market) / Var(R_market) = ρ_{am} × (σ_asset / σ_market)", note: "β>1: more volatile than market; β<1: less; β=0: uncorrelated. CAPM: Required Return = Rf + β(Rm−Rf). Portfolio beta = weighted average of individual betas. Only systematic risk is priced." },
  { id: "F-Risk5", sub: "Risk", tag: "Operational Risk", name: "Operational Risk Capital — Basic Indicator Approach (BIA)", f: "OpRisk Capital = Average of (Annual Gross Income × 15%) for positive income years (last 3 years)", note: "BIA: 15% alpha factor of average positive gross income. Standardised Approach (SA): 12-18% beta by business line. Advanced Measurement Approach (AMA): internal models. India: most banks use SA." },
  { id: "F-Risk6", sub: "Risk", tag: "Liquidity Risk", name: "Liquidity Stress Testing", f: "Survival Days = Liquid Assets / Peak Daily Outflow | LCR = HQLA / Net Cash Outflows (30 days) ≥ 100% | Stress scenarios: mild (10%), moderate (20%), severe (40%) run", note: "HQLA = Level 1 (G-Sec, T-Bill, SLR securities at 100%) + Level 2A (PSU bonds at 85%) + Level 2B (equity at 50%). RBI mandates banks conduct internal stress tests at all three severity levels quarterly." },
  { id: "F-Risk7", sub: "Risk", tag: "Credit Risk", name: "Credit Concentration Risk", f: "Single borrower limit: 15% of Capital Funds | Group: 25% of Capital Funds | Infrastructure: 20% (single), 30% (group) | Capital Funds = Tier I + Tier II capital", note: "Exposure = funded + non-funded (at 100% for LC/BG). Infrastructure sector higher limits (20/30%). Banks must monitor concentration by sector, geography, and individual borrowers. Off-balance sheet: credit equivalent for LEF." },
  { id: "F-Risk8", sub: "Risk", tag: "Market Risk", name: "Information Ratio (IR)", f: "IR = Active Return / Tracking Error = (Rp − Benchmark Return) / σ(Rp − Benchmark)", note: "Measures active fund manager skill. Higher IR = better excess return per unit of active risk vs benchmark. IR > 0.5 considered good; > 1.0 excellent. Used in investment portfolio evaluation and Treasury performance measurement." },
  // IT
  { id: "F-IT1", sub: "IT", tag: "BCP/DR", name: "RTO & RPO — Business Continuity Definitions", f: "RTO = Maximum tolerable downtime after disruption | RPO = Maximum tolerable data loss (time since last backup)", note: "RBI DR guidelines: Core banking RTO ≤ 2 hours for large banks. RPO ≤ 30 minutes for mission-critical systems. Hot standby: RTO near-zero; Warm standby: RTO hours; Cold standby: RTO days." },
  { id: "F-IT2", sub: "IT", tag: "Infrastructure", name: "System Availability & Uptime SLA", f: "Availability % = [(Total Time − Downtime) / Total Time] × 100 | 99.9% = 8.76 hr/yr downtime | 99.99% = 52.6 min/yr | 99.999% = 5.26 min/yr", note: "Core banking: target 99.99%. ATMs: 99.5%. UPI: NPCI mandates ≥99.95% for member banks. SLA breach triggers penalties. Five-nines (99.999%) = Tier IV data centre standard." },
  { id: "F-IT3", sub: "IT", tag: "Infrastructure", name: "MTBF and MTTR (Reliability Metrics)", f: "MTBF = Total Uptime / Number of Failures | MTTR = Total Downtime / Number of Repairs | Availability = MTBF / (MTBF + MTTR)", note: "IT BCP teams track MTBF and MTTR for core systems. Higher MTBF + lower MTTR = more reliable infrastructure. Used in vendor SLA monitoring and internal IT performance reporting." },
  { id: "F-IT4", sub: "IT", tag: "Cybersecurity", name: "Fraud Model Accuracy — Precision, Recall, F1 Score", f: "Precision = TP/(TP+FP) | Recall = TP/(TP+FN) | F1 = 2PR/(P+R) | Accuracy = (TP+TN)/(TP+TN+FP+FN)", note: "Fraud detection: Recall (catching all frauds) prioritised over Precision (avoiding false alarms). Missing a real fraud (FN) > customer friction from false alert (FP). F1-score balances both for imbalanced fraud datasets." },
  { id: "F-IT5", sub: "IT", tag: "Cybersecurity", name: "Encryption Standards — Key Lengths", f: "AES-256: symmetric encryption (data at rest/transit) | RSA-2048: asymmetric/PKI (minimum) | SHA-256: hashing | TLS 1.2/1.3: transport security", note: "RBI mandates AES-256 for customer data. TLS 1.2 minimum for banking APIs (TLS <1.2 deprecated). Digital certificates: RSA-2048 or ECC-256 minimum. End-to-end encryption mandatory for digital payments." },
  // HR
  { id: "F-HR1", sub: "HR", tag: "Employee Benefits", name: "Gratuity Calculation (Gratuity Act 1972)", f: "Gratuity = (Last Monthly Wages × 15 / 26) × Completed Years of Service | Max: ₹20 lakh (w.e.f. 2018)", note: "Wages = Basic + DA only. Applicable: 10+ employee establishments; 5 years continuous service required (4 yrs 240 days = 5 if 6-day week). 15/26 = 15 days per 26 working days per month." },
  { id: "F-HR2", sub: "HR", tag: "Employee Benefits", name: "EPF Contribution (EPF Act 1952)", f: "Employee: 12% of Basic+DA | Employer: 3.67% to EPF + 8.33% to EPS | EPS cap: ₹1,250/month (₹15,000 wage ceiling × 8.33%)", note: "Mandatory for establishments with 20+ employees. Wage ceiling for mandated PF: ₹15,000/month (voluntary for higher earners). SS Code 2020 maintains similar structure but extends to gig workers via welfare fund." },
  { id: "F-HR3", sub: "HR", tag: "Employee Benefits", name: "Bonus (Payment of Bonus Act / Wage Code 2019)", f: "Min Bonus: 8.33% of annual wages | Max: 20% | Eligibility: earning ≤₹21,000/month | Wage ceiling for calc: ₹7,000/month or Min Wage (whichever higher)", note: "Must be paid within 8 months of accounting year-end. All employees earning ≤₹21,000/month eligible — minimum bonus payable even if no profit. Above ₹21,000: no statutory bonus obligation." },
  { id: "F-HR4", sub: "HR", tag: "Workforce Analytics", name: "Attrition Rate", f: "Attrition Rate = (Employees who Left / Average Employees during period) × 100 | Avg = (Opening + Closing) / 2", note: "Indian banking: PSBs ~5%; private banks ~20-25%; fintech/NBFCs ~30-35%. High attrition = high replacement cost (50-200% of annual salary per exit including recruitment + training + ramp-up productivity loss)." },
  { id: "F-HR5", sub: "HR", tag: "Training", name: "Training ROI (Phillips Level 5)", f: "Training ROI = [(Benefits from Training − Cost of Training) / Cost of Training] × 100", note: "Phillips 5-level model: 1.Reaction, 2.Learning, 3.Behaviour, 4.Business Results, 5.ROI. Level 4-5 requires control group comparison. Benefits measured as: productivity increase, error reduction, attrition savings." },
  { id: "F-HR6", sub: "HR", tag: "Employee Benefits", name: "Leave Encashment", f: "Encashment = (Basic + DA) / 30 × Number of EL days encashed | Tax exemption: up to ₹25 lakh at retirement (w.e.f. FY 2023-24)", note: "Earned Leave (EL): typically 30 days/year in banks. Max accumulation: 240-300 days. EL encashment during service: taxable. At retirement: exempt up to ₹25 lakh. LTC (Leave Travel Concession): separate entitlement." },
  { id: "F-HR7", sub: "HR", tag: "Employee Benefits", name: "ESI Contribution (ESI Act 1948 / SS Code 2020)", f: "Employee: 0.75% of wages | Employer: 3.25% of wages | Eligibility: employees earning ≤₹21,000/month | Establishments: 10+ employees", note: "ESIC provides medical benefits (hospitalisation, medicines) + disability + maternity + dependant benefit. Wage ceiling: ₹21,000/month. Banks with 10+ employees covered — relevant for workmen staff." },
  // Rural Banking
  { id: "F-Rural1", sub: "Rural", tag: "Agricultural Finance", name: "KCC Credit Limit (Scale of Finance Method)", f: "KCC Crop Limit = Scale of Finance (₹/hectare) × Acreage | Add: 10% for repairs/post-harvest | Total KCC limit reviewed annually; max ₹3 lakh for standard KCC", note: "Scale of Finance = DLTC (District Level Technical Committee) approved cost of cultivation. KCC also includes: allied activities, consumption needs (10%), maintenance. Interest subvention makes effective rate 4% p.a." },
  { id: "F-Rural2", sub: "Rural", tag: "PSL", name: "Priority Sector Lending — Target Calculation", f: "PSL Target Base = Max(ANBC, CEOBE) | Overall: 40% | Agriculture: 18% | SM Farmers: 8% | Weaker Sections: 12% | MSME: 7.5%", note: "ANBC = Net Bank Credit + RIDF deposits + HTM non-SLR bonds. Shortfall → RIDF (NABARD) / SIDBI / NHB at below-market rates (penalty mechanism). PSLCs tradeable on CBS: 4 types — Agri, SF/MF, Micro, General." },
  { id: "F-Rural3", sub: "Rural", tag: "Agricultural Finance", name: "NABARD Refinance Eligibility", f: "Eligible refinance = Actual disbursement to qualifying beneficiaries | ST refinance rate: ~4-5% | LT refinance: ~6-7% | Maximum: up to 100% of disbursement (scheme-specific)", note: "NABARD STD: covers KCC/crop loan disbursements by SCBs, DCCBs, RRBs. LT refinance: irrigation, mechanisation, land development, fisheries. Refinance reduces banks' cost of agricultural lending, enables lower lending rates." },
  { id: "F-Rural4", sub: "Rural", tag: "Agricultural Insurance", name: "PMFBY — Farmer Premium Rates", f: "Kharif: farmer pays ≤2% of Sum Insured | Rabi: ≤1.5% | Horticulture/Commercial: ≤5% | Government pays actuarial premium excess above farmer share", note: "PMFBY voluntary for farmers (post-2020 restructuring). Sum insured = value of crop × area. State govts can opt out of PMFBY. Technology: drones + satellite for crop loss assessment replacing manual survey." },
  { id: "F-Rural5", sub: "Rural", tag: "Microfinance", name: "SHG Loan Sizing (NABARD Linkage Norms)", f: "Phase I: Bank loan = 4× SHG corpus | Phase II: Bank loan = 8× SHG corpus (after satisfactory repayment) | Typical individual loan: ₹10,000 − ₹1,00,000", note: "SHG corpus = group members' savings. JLG (Joint Liability Group): no savings; group guarantee structure. SBLP (SHG-Bank Linkage Programme): 10 crore+ groups linked nationally as of 2024, outstanding ₹2.5 lakh crore." },
  // Central Banking
  { id: "F-Central1", sub: "Central", tag: "Monetary Policy", name: "Money Supply Definitions (M0/M1/M3)", f: "M0 = Currency + Bankers' Deposits + Other Deposits with RBI | M1 = M0 + Demand Deposits | M3 = M1 + Time Deposits | M3 = Broad Money", note: "RBI monitors M3 growth as monetary policy indicator. M3 / GDP ratio = financial deepening. High M3 growth without corresponding GDP growth → inflationary pressure. Reserve Money (M0) = RBI's liability." },
  { id: "F-Central2", sub: "Central", tag: "Monetary Policy", name: "Fisher Equation (Real vs Nominal Interest Rate)", f: "Exact: (1+r) = (1+R) / (1+π) | Approximate: r ≈ R − π | r=real rate, R=nominal, π=inflation", note: "Real policy rate = Repo rate − CPI inflation. When real rate > 0: contractionary stance. When real rate < 0: accommodative. RBI's current real rate (Feb 2026): 5.25% − ~4.5% CPI ≈ 0.75% (mildly positive)." },
  { id: "F-Central3", sub: "Central", tag: "Monetary Policy", name: "Taylor Rule (Policy Rate Guidance)", f: "i = r* + π + 0.5(π − π*) + 0.5(Y_gap) | r*=neutral real rate (~1%), π*=target (4%), Y_gap=output gap", note: "Systematic rule for setting policy rates. RBI MPC uses similar framework informally. If inflation > 4%: raise i. If output below potential: lower i. FIT (Flexible Inflation Targeting) since 2016 formalises this approach." },
  { id: "F-Central4", sub: "Central", tag: "Forex", name: "Purchasing Power Parity (PPP)", f: "Absolute: S = P_d / P_f | Relative: ΔS ≈ π_d − π_f | Example: India CPI 5%, US CPI 2% → INR depreciates ~3%/year", note: "PPP explains long-run FX trends. India's persistent higher inflation vs US → systematic INR depreciation trend over decades. REER (Real Effective Exchange Rate) measures actual competitiveness vs PPP benchmark." },
  { id: "F-Central5", sub: "Central", tag: "Fiscal Policy", name: "FRBM Targets (Fiscal Responsibility Act)", f: "Fiscal Deficit: ≤3% of GDP | Primary Deficit: → 0% | Debt-to-GDP: ≤60% (Centre) | Revenue Deficit: 0% | Effective Revenue Deficit: 0%", note: "FRBM Act 2003. NK Singh Committee (2017): medium-term glide path to 3% FD. Escape clause invoked 2020-21, 2021-22 (COVID). Centre's FY25 target: 5.1% FD/GDP (higher than 3% due to pandemic legacy)." },
  { id: "F-Central6", sub: "Central", tag: "Forex", name: "Forex Reserve Adequacy", f: "Import Cover = Forex Reserves / Monthly Imports | Guidotti Rule: Reserves ≥ ST External Debt | IMF ARA: composite of imports + ST debt + broad money + liabilities", note: "India forex reserves ~$700B (2025) = ≈11 months import cover. Well above minimum 3 months. Guidotti-Greenspan Rule: reserves cover at least 1 year of short-term debt. Excess reserves earn low returns — opportunity cost." },
  { id: "F-Central7", sub: "Central", tag: "Monetary Policy", name: "LAF Corridor Rates (Current)", f: "SDF (Floor): Repo − 25 bps = 5.00% | Repo Rate: 5.25% | MSF (Ceiling): Repo + 25 bps = 5.50% | Bank Rate = MSF Rate", note: "LAF corridor width = 50 bps (SDF to MSF). Repo = key policy rate; SDF absorbs surplus liquidity; MSF provides emergency overnight funds. As of Feb 2026 after 125 bps easing cycle 2025-26." },
  { id: "F-Central8", sub: "Central", tag: "Monetary Policy", name: "CPI Basket Weights (India)", f: "Food & Beverages: 45.86% | Fuel & Light: 6.84% | Core (Misc+Housing+Clothing+Pan+Health+Education+Transport): 47.30% | Core CPI = Headline − Food − Fuel", note: "MPC targets headline CPI at 4% (±2% band). Food inflation: volatile, supply-side — limited monetary policy impact. Core CPI: tracks demand-pull inflation — primary signal for MPC rate decisions. Base year: 2012." }
];

export const RBI_CIRCULARS = [
  {
    id: "CIRC-001",
    date: "May 2026",
    title: "Prudential Norms on Risk Weights for Consumer Credit",
    summary: "RBI increased risk weights on unsecured retail consumer loans (credit cards, personal loans) from 100% to 125% for banks, urging higher capital buffers. Housing, education, and vehicle loans remain exempt.",
    relevance: 95,
    tag: "BFM · Capital Requirements",
    subjectId: "BFM",
    topicId: "T-BFM-B1"
  },
  {
    id: "CIRC-002",
    date: "April 2026",
    title: "Master Direction – Liquidity Risk Management Framework",
    summary: "Stricter reporting rules for daily LCR monitoring. RBI mandates banks to conduct stress tests reflecting sudden online banking withdrawal panic, adjusting retail deposit run-off assumptions.",
    relevance: 90,
    tag: "BFM · ALM & Liquidity",
    subjectId: "BFM",
    topicId: "T-BFM-D1"
  },
  {
    id: "CIRC-003",
    date: "March 2026",
    title: "Revision in NPA Classification Guidelines under MSME Act",
    summary: "Revises threshold rules for classifying stressed MSME accounts. Restructuring proposals can be implemented within 180 days of standard account classification under specialized bank committees.",
    relevance: 88,
    tag: "ABM · Credit Management",
    subjectId: "ABM",
    topicId: "T-ABM-C2"
  },
  {
    id: "CIRC-004",
    date: "May 2026",
    title: "Framework for Cyber Security Incident Reporting",
    summary: "Mandates reporting of all security breaches, ransomware threats, and DDoS events to RBI and CERT-In within 6 hours of detection, with compulsory root-cause analysis submittals in 15 days.",
    relevance: 92,
    tag: "IT · Cybersecurity",
    subjectId: "IT",
    topicId: "T-IT-C1"
  },
  {
    id: "CIRC-005",
    date: "March 2026",
    title: "Master Directions on KYC — Periodic Re-KYC & Video KYC (V-CIP)",
    summary: "RBI revised periodic KYC update intervals: Low-risk customers every 10 years, medium-risk every 8 years, high-risk (including PEPs) every 2 years. Video Customer Identification Process (V-CIP) is now a mandatory option for digital account opening. Aadhaar-based e-KYC via OTP and biometric authentication explicitly permitted for seamless onboarding.",
    relevance: 93,
    tag: "ABM · KYC / AML Compliance",
    subjectId: "ABM",
    topicId: "T-ABM-D1"
  },
  {
    id: "CIRC-006",
    date: "April 2026",
    title: "Revised Guidelines on Corporate Governance in Private Sector Banks",
    summary: "RBI mandated formal separation of MD & CEO role from Board Chairperson in all private sector banks. Part-time Chairman must be a non-executive director. Independent directors must form at least one-third of the Board. Cooling-off period of 3 years introduced for former bank employees seeking Board positions. Maximum MD & CEO tenure capped at 15 years in a single bank.",
    relevance: 87,
    tag: "ABM · Corporate Governance",
    subjectId: "ABM",
    topicId: "T-ABM-D2"
  },
  {
    id: "CIRC-007",
    date: "February 2026",
    title: "Enhancement in Fraud Reporting Framework — Digital & Cyber Frauds",
    summary: "RBI expanded the fraud classification framework to cover new digital fraud categories: SIM swap attacks, business email compromise (BEC), and deepfake-based social engineering frauds. Flash reporting timeline reduced to 6 hours for cyber frauds above ₹5 Crore. Banks must retain fraud incident logs for 180 days and make them accessible to RBI inspection teams. Dedicated fraud risk officer role mandated in banks with total assets above ₹10,000 Crore.",
    relevance: 91,
    tag: "ABM · Fraud Risk Management",
    subjectId: "ABM",
    topicId: "T-ABM-D3"
  },
  {
    id: "CIRC-008",
    date: "January 2026",
    title: "Working Capital Assessment for MSME — Nayak Committee Turnover Limit Revision",
    summary: "RBI revised the Nayak Committee turnover method applicability threshold from ₹5 Crore to ₹7.5 Crore for MSME borrowers. Banks may adopt the Projected Turnover method (20% of projected annual turnover as working capital limit; 5% as borrower margin) for limits up to ₹7.5 Crore without requiring full CMA data. Borrowers above ₹7.5 Crore must submit detailed CMA data and follow Tandon Committee methods.",
    relevance: 88,
    tag: "ABM · Credit Management",
    subjectId: "ABM",
    topicId: "T-ABM-C1"
  },
  {
    id: "CIRC-009",
    date: "April 2023",
    title: "Master Directions on IT Governance, Risk and Controls (IT Framework 2023)",
    summary: "Comprehensive IT governance framework replacing 2011 guidelines. Key mandates: Board-approved IT strategy; dedicated IT Steering Committee; CISO (Chief Information Security Officer) as independent function reporting to Board; annual IT risk assessment aligned with IS audit; mandatory VAPT (Vulnerability Assessment & Penetration Testing) for all internet-facing systems; security patch management within 7 days (critical) to 30 days (moderate); incident response playbook with RBI escalation within 6 hours for significant cyber events.",
    relevance: 90,
    tag: "IT · IT Governance",
    subjectId: "IT",
    topicId: "T-IT-B1"
  },
  {
    id: "CIRC-010",
    date: "September 2022",
    title: "Guidelines on Digital Lending — Regulated Entities and Lending Service Providers",
    summary: "RBI mandated: (1) all digital loan disbursals directly to borrower's bank account — no pass-through via LSP/NBFC accounts; (2) Key Fact Statement (KFS) mandatory in vernacular language before loan agreement; (3) regulated entity (bank/NBFC) fully responsible for LSP actions — cannot delegate accountability; (4) First Loss Default Guarantee (FLDG) capped at 5% of qualifying loan portfolio; (5) Annual Percentage Rate (APR) disclosure on all digital loans; (6) no penal interest — only flat penal charges, not compounded; (7) cooling-off period mandatory for borrower to exit loan.",
    relevance: 93,
    tag: "ABM · Digital Lending",
    subjectId: "ABM",
    topicId: "T-ABM-D1"
  },
  {
    id: "CIRC-011",
    date: "November 2021",
    title: "Reserve Bank — Integrated Ombudsman Scheme (IOS) 2021",
    summary: "RBI merged three separate ombudsman schemes (Banking Ombudsman Scheme 2006, NBFC Ombudsman Scheme 2018, Ombudsman Scheme for Digital Transactions 2019) into a single Integrated Ombudsman Scheme. Key features: 'One Nation One Ombudsman' — 'Submit and Forget' approach (complainant submits once, RBI routes to appropriate authority); maximum award ₹20 lakh (pecuniary) + ₹1 lakh (non-pecuniary/mental agony); no complaint fee; time limit 1 year from bank's final response (or 13 months if no response); appeal to Appellate Authority (RBI Deputy Governor) within 30 days; online portal cms.rbi.org.in.",
    relevance: 88,
    tag: "BRBL · Banking Ombudsman",
    subjectId: "BRBL",
    topicId: "T-BRBL-A1"
  },
  {
    id: "CIRC-012",
    date: "October 2021",
    title: "Scale Based Regulation (SBR) Framework for NBFCs",
    summary: "RBI moved from activity-based to size/risk-based NBFC regulation in four layers: Base Layer (BL) — NBFCs <₹1,000 crore assets or deposit-taking NBFCs, lighter regulation; Middle Layer (ML) — ₹1,000-₹50,000 crore, systemically important, enhanced norms (CRAR 15%, 90-day NPA, ALM); Upper Layer (UL) — top 10 identified high-risk NBFCs, bank-equivalent norms, mandatory listing within 3 years; Top Layer (TL) — reserved for extreme systemic risk cases. Effective October 2022.",
    relevance: 89,
    tag: "Central · NBFC Regulation",
    subjectId: "Central",
    topicId: "T-Central-F3"
  },
  {
    id: "CIRC-013",
    date: "October 2019",
    title: "Interest Rates on Loans Linked to External Benchmarks (EBLR Mandate)",
    summary: "RBI mandated all new floating rate loans for retail and MSME borrowers be linked to an external benchmark from October 2019. Permitted benchmarks: RBI Repo Rate (most common), 91-day T-Bill rate, 182-day T-Bill rate, or any FBIL-published benchmark. Banks must: reset rates at minimum every 3 months; keep the credit risk spread fixed throughout tenure (unless credit assessment changes); cannot selectively apply reset only for rate increases. MCLR continues for corporate loans and existing loan accounts.",
    relevance: 92,
    tag: "ABM · Lending Rates",
    subjectId: "ABM",
    topicId: "T-ABM-A7"
  },
  {
    id: "CIRC-014",
    date: "February 2020",
    title: "Revised KCC Scheme — Extension to Animal Husbandry and Fisheries",
    summary: "RBI operationalised Budget 2018-19 extension of Kisan Credit Card (KCC) to fisheries and animal husbandry farmers. Key provisions: (1) AH-KCC covers dairy, poultry, sheep/goat, piggery working capital; (2) Fisheries-KCC covers fish purchase, boat/net maintenance up to ₹2 lakh as TL component + WC revolving limit; (3) interest subvention: 2% GOI subvention + 3% prompt repayment incentive = 4% effective rate; (4) no collateral for KCC limits up to ₹1.60 lakh; (5) validity 5 years with annual review; (6) crop/asset insurance mandatory. PSL classification: Agriculture sub-category.",
    relevance: 85,
    tag: "Rural · KCC",
    subjectId: "Rural",
    topicId: "T-Rural-B1"
  },
  {
    id: "CIRC-015",
    date: "February 2020",
    title: "Restructured PMFBY — Voluntary Enrollment and State Flexibility",
    summary: "Government of India restructured PMFBY from February 2020. Key changes: (1) enrollment made VOLUNTARY for loanee farmers (previously compulsory); (2) state governments can opt out if actuarial premiums are too high; (3) farmer premium caps unchanged: 2% (kharif), 1.5% (rabi), 5% (horticulture); (4) Centre-State premium sharing revised: 50:50 for northeastern states and UTs; (5) technology integration mandated: drones, satellite imagery, and smartphone-based crop cutting experiments for loss assessment; (6) claim settlement within 2 months post-harvest using remote sensing data.",
    relevance: 82,
    tag: "Rural · Crop Insurance",
    subjectId: "Rural",
    topicId: "T-Rural-C5"
  },
  {
    id: "CIRC-016",
    date: "November 2021",
    title: "Revised Prompt Corrective Action (PCA) Framework for Scheduled Commercial Banks",
    summary: "RBI revised PCA framework effective November 2021 (applicable from April 2022). Trigger indicators: (1) Capital — CET1 < 4.5% (Risk Threshold 1) or Tier 1 < 6% or CRAR < 9%; (2) Asset Quality — Net NPA ratio > 6%; (3) Leverage Ratio < 3.5%. Restrictions by severity level: Level 1-3 impose increasing constraints (no new branches, hiring restrictions, dividend ban, credit concentration limits, higher provisioning). UCBs (Urban Co-operative Banks) brought under PCA from 2020. Objective: early intervention before bank becomes insolvent.",
    relevance: 90,
    tag: "Central · PCA",
    subjectId: "Central",
    topicId: "T-Central-E2"
  },
  {
    id: "CIRC-017",
    date: "April 2023",
    title: "Guidelines on Interest Rate Risk in the Banking Book (IRRBB)",
    summary: "RBI issued comprehensive IRRBB guidelines. Key requirements: (1) measure IRRBB under both EVE (Economic Value of Equity) and NII (Net Interest Income) perspectives; (2) prescribed rate shocks: six scenarios including parallel ±200 bps, steepener, flattener, short-rate up/down; (3) EVE outlier test: banks with EVE decline >15% of Tier 1 capital under 200 bps shock flagged for supervisory attention; (4) NII perspective: 12-month projection horizon; (5) Board-approved IRRBB policy, limits on EVE and NII sensitivity; (6) monthly internal IRRBB reporting; (7) IRRBB integrated into ICAAP under Pillar 2.",
    relevance: 87,
    tag: "BFM · Interest Rate Risk",
    subjectId: "BFM",
    topicId: "T-BFM-D2"
  },
  {
    id: "CIRC-018",
    date: "August 2023",
    title: "Penal Charges — No Compounding of Penal Interest",
    summary: "RBI clarified that regulated entities (banks, NBFCs) shall NOT charge 'penal interest' (compounded) on loan defaults — only a flat, non-compounding 'penal charge' is permissible. Key: (1) penal charges must be reasonable and not designed as revenue enhancement; (2) no capitalization of penal charges; (3) they shall not exceed the contractual interest rate; (4) disclosure in loan agreement as a specific line item; (5) waiver in genuine hardship cases encouraged. Change effective January 2024. Applies to all loan products including credit cards.",
    relevance: 84,
    tag: "ABM · Consumer Protection",
    subjectId: "ABM",
    topicId: "T-ABM-D1"
  },
  {
    id: "CIRC-019",
    date: "July 2024",
    title: "Master Directions — Cyber Resilience and Digital Payment Security Controls",
    summary: "Supersedes IT Framework 2023 with more prescriptive security controls for digital payments. Key: (1) CISO must report directly to Board's IT Strategy Committee — operationally independent from CTO; (2) mandatory multi-factor authentication (MFA) for all customer-initiated transactions above ₹10,000; (3) device binding and app-level security for mobile banking; (4) third-party risk management: IT vendor due diligence, no critical banking function to single vendor; (5) data localisation: all payment data stored only in India; (6) incident reporting via CIMS portal within 6 hours for systemic cyber events; (7) annual Red Team exercises for banks with total assets >₹10,000 crore.",
    relevance: 93,
    tag: "IT · Cybersecurity",
    subjectId: "IT",
    topicId: "T-IT-C1"
  },
  {
    id: "CIRC-020",
    date: "March 2024",
    title: "Draft Framework on Climate Risk and Sustainable Finance for Regulated Entities",
    summary: "RBI released draft climate risk framework (consultative). Key elements: (1) banks to identify and assess physical risks (flood, drought, extreme weather impacting collateral and borrower cash flows) and transition risks (carbon-intensive sectors facing regulatory/market shifts); (2) climate stress testing to be integrated into ICAAP under Pillar 2; (3) ESG disclosures recommended aligned with TCFD framework — Board oversight of climate risks; (4) green finance: sovereign green bonds (issued from 2023) eligible for SLR portfolio; (5) IFSCA GIFT City green bond guidelines; (6) no mandatory green taxonomy initially — phased consultative approach.",
    relevance: 78,
    tag: "BFM · Climate Risk / ESG",
    subjectId: "BFM",
    topicId: "T-BFM-B3"
  }
];

export const MODULE_SUMMARIES = [
  {
    id: "MS-ABM-A", moduleId: "ABM-A", subjectId: "ABM",
    title: "Banking Environment & Monetary Policy",
    bullets: [
      "RBI operates under RBI Act 1934; Banking Regulation Act 1949 governs bank licensing, branch expansion, audit, capital, and voluntary/compulsory winding up",
      "Monetary policy instruments: CRR (4%), SLR (18%), Repo Rate (5.25%), SDF (5.00%), MSF (5.50%) — as of Feb 2026",
      "MCLR replaced Base Rate in 2016; EBLR replaced MCLR for retail/MSME floating rate loans from Oct 2019; Repo Rate is the most common external benchmark",
      "NIM, ROA, ROE are primary bank profitability metrics; ROA ≥1% = well-managed bank; NIM benchmark 2.5–3.5% PSBs",
      "Money multiplier = 1/CRR; higher CRR → lower MM → tighter money supply; LAF corridor (SDF to MSF) manages day-to-day liquidity"
    ],
    mustRemember: ["CRR 4% | SLR 18% | Repo 5.25% | SDF 5.00% | MSF 5.50%", "EBLR: quarterly reset mandatory | repo as benchmark | credit spread fixed for loan tenure", "Money Multiplier = 1/CRR | Fisher Equation: r ≈ R − π"],
    formulaIds: ["F-ABM14", "F-ABM15", "F-ABM17", "F-Central7"],
    topicIds: ["T-ABM-A1", "T-ABM-A2", "T-ABM-A3", "T-ABM-A4", "T-ABM-A5", "T-ABM-A6", "T-ABM-A7"]
  },
  {
    id: "MS-ABM-B", moduleId: "ABM-B", subjectId: "ABM",
    title: "Credit Management & Appraisal",
    bullets: [
      "3 Cs → 5 Cs of Credit (Character, Capacity, Capital, Collateral, Conditions) — also 7 Ps in modern assessment",
      "Working capital: Tandon M1 = 0.75×(CA−CL); Tandon M2 = 0.75×CA − CL; Nayak = 20% of projected turnover (up to ₹7.5 crore); Cash Budget method for seasonal industries",
      "DSCR = (NPAT + Dep + Interest on TL) / (Installment + Interest on TL) — ideal ≥1.25; project lending ≥1.50",
      "Current Ratio benchmark ≥1.33; DER ≤2:1 for manufacturing; ICR ≥2.5x for term loans",
      "CMA data (Annual Report format): Funds Flow, projected Balance Sheet, Profitability — required above Nayak threshold"
    ],
    mustRemember: ["Nayak: 20% of turnover (bank) + 5% borrower margin | Tandon M2 > M1 conservatism", "DSCR: numerator includes interest+repayment | not just EBITDA", "PSL: 40% ANBC | Agriculture 18% | SMF 8% | Weaker Sections 12%"],
    formulaIds: ["F-ABM1", "F-ABM2", "F-ABM3", "F-ABM4", "F-ABM8", "F-ABM9", "F-ABM10"],
    topicIds: ["T-ABM-B1", "T-ABM-B2", "T-ABM-B3", "T-ABM-B4", "T-ABM-B5"]
  },
  {
    id: "MS-ABM-C", moduleId: "ABM-C", subjectId: "ABM",
    title: "NPA Management, Recovery & Restructuring",
    bullets: [
      "NPA = Non-Performing Asset: 90 DPD for standard classification (banks and NBFC-ND-SI post-2022)",
      "Substandard: up to 12 months as NPA; Doubtful: 12+ months as NPA (D1/D2/D3 by age); Loss: fully written off or identified for write-off",
      "Provisioning: standard 0.25-0.40%; substandard 15%; doubtful D1 25%, D2 40%, D3 100%; Loss 100%",
      "GNPA Ratio = Gross NPA/Gross Advances; Net NPA Ratio = (GNPA−Provisions)/(Advances−Provisions); PCR = Provisions/GNPA ≥70%",
      "Recovery: SARFAESI (60-day notice) for secured NPA >₹1L; DRT for ≥₹20L; IBC for ≥₹1 crore; Lok Adalat <₹20L"
    ],
    mustRemember: ["90 DPD → NPA | Doubtful 1/2/3 provisions 25/40/100%", "PCR ≥70% desirable | GNPA <5% healthy | 5-10% moderate | >10% poor", "SARFAESI: 60 days notice | IBC CIRP: max 330 days | DRT: ≥₹20L"],
    formulaIds: ["F-ABM5", "F-ABM6", "F-ABM7", "F-BRBL1", "F-BRBL2", "F-BRBL3"],
    topicIds: ["T-ABM-C1", "T-ABM-C2", "T-ABM-C3", "T-ABM-C4", "T-ABM-C5"]
  },
  {
    id: "MS-ABM-E", moduleId: "ABM-E", subjectId: "ABM",
    title: "Business Mathematics for Banking",
    bullets: [
      "TVM: FV = PV(1+r)^n; PV = FV/(1+r)^n; EAR = (1+r/m)^m − 1; Rule of 72 for doubling time",
      "EMI = P×r×(1+r)^n/[(1+r)^n−1]; Annuity PV = A×[1−(1+r)^{−n}]/r; Perpetuity PV = A/r",
      "Statistics: AM, Median, Mode, GM, Harmonic Mean; Variance and SD; Coefficient of Variation (CV) for comparing risk",
      "Probability: P(A∪B) = P(A)+P(B)−P(A∩B); Bayes theorem for conditional updating; Normal distribution Z = (X−μ)/σ",
      "Regression: Y = a + bX; Pearson r = Cov(X,Y)/(σx×σy); r² = coefficient of determination (% variation explained)"
    ],
    mustRemember: ["EAR = (1+r/m)^m − 1 | Rule of 72: years = 72/rate", "CV = (SD/Mean)×100 — compares risk across different-mean datasets", "Bayes: P(B|A) = P(A|B)×P(B) / P(A) — updates probability with new evidence"],
    formulaIds: ["F-ABM13"],
    topicIds: ["T-ABM-E1", "T-ABM-E2", "T-ABM-E3", "T-ABM-E4", "T-ABM-E5", "T-ABM-E6", "T-ABM-E7", "T-ABM-E8"]
  },
  {
    id: "MS-BFM-A", moduleId: "BFM-A", subjectId: "BFM",
    title: "Capital Adequacy & Basel Framework",
    bullets: [
      "Basel III: CRAR ≥9% (RBI); CET1 ≥5.5% + CCB 2.5% = 8% effective; Tier 1 ≥7% (India: 7.375% with CCB); Tier II ≤Tier I",
      "D-SIBs (Domestic Systemically Important Banks): SBI, HDFC Bank, ICICI Bank — additional capital surcharge 0.6–0.8%",
      "CRAR = (Tier I + Tier II) / RWA × 100 | Leverage Ratio = Tier I / Total Exposure ≥3.5% (non-risk-based backstop)",
      "Risk weights: sovereign 0%, PSU banks 20%, retail 75%, corporate 100%, unsecured retail 75-125%, consumer credit 125%",
      "LCR (≥100%) for short-term liquidity; NSFR (≥100%) for structural 1-year liquidity; stress testing quarterly"
    ],
    mustRemember: ["CRAR ≥9% (RBI) | CET1 + CCB = 8% effective | Tier II ≤ Tier I", "LCR = HQLA/NCO ≥100% | NSFR = ASF/RSF ≥100%", "D-SIB surcharge: SBI 0.8%, HDFC/ICICI 0.6%"],
    formulaIds: ["F-BFM1", "F-BFM2", "F-BFM3", "F-ABM20"],
    topicIds: ["T-BFM-A1", "T-BFM-A2", "T-BFM-A3", "T-BFM-A4"]
  },
  {
    id: "MS-BFM-C", moduleId: "BFM-C", subjectId: "BFM",
    title: "Market Risk, Bonds & Treasury",
    bullets: [
      "Bond Price = Σ[C/(1+y)^t] + FV/(1+y)^n; Price-yield inverse; discount if YTM>coupon; premium if YTM<coupon",
      "YTM interpolation: YTM = r_low + [(P_low−P_target)/(P_low−P_high)] × (r_high−r_low); if price<FV, start trials above coupon",
      "Macaulay Duration = Σ[t×PV(CF)]/Price; Modified Duration = D_mac/(1+YTM); %ΔP ≈ −MD×Δy",
      "Convexity: actual price change > duration prediction for large moves; positive convexity always benefits holder",
      "VaR = μ − z×σ×√t; 99% confidence z=2.326; HTM bonds not MTM; AFS bonds MTM to P&L or OCI"
    ],
    mustRemember: ["YTM interpolation formula | if price<FV: YTM>coupon | start trials above coupon rate", "MD = D_mac/(1+YTM) | %ΔP ≈ −MD×Δy | DV01 = MD×Price×0.0001", "VaR z-scores: 90%=1.645 | 95%=1.96 | 99%=2.326"],
    formulaIds: ["F-BFM4", "F-BFM5", "F-BFM6", "F-BFM7", "F-BFM8", "F-BFM9"],
    topicIds: ["T-BFM-C1", "T-BFM-C2", "T-BFM-C3", "T-BFM-C4", "T-BFM-C5", "T-BFM-C6"]
  },
  {
    id: "MS-BFM-D", moduleId: "BFM-D", subjectId: "BFM",
    title: "ALM, Liquidity & Interest Rate Risk",
    bullets: [
      "ALM framework: measures and manages mismatches between assets and liabilities across time buckets (overnight to 5+ years)",
      "NII sensitivity: ΔNII = GAP × Δr | Positive GAP (RSA>RSL): NII rises with rates | Negative GAP: NII falls with rate hikes",
      "EVE: economic value of equity; ΔEVE = −MD_A×Asset_MV×Δy + MD_L×Liab_MV×Δy | long-term IR risk measure",
      "IRRBB (RBI 2023): EVE outlier = EVE decline >15% of Tier 1 under ±200bps shock; NII projection for 12 months",
      "Liquidity: LCR for 30-day stress; NSFR for 1-year structural; HQLA = Level 1 (100%) + 2A (85%) + 2B (50%, capped)"
    ],
    mustRemember: ["GAP = RSA − RSL | Positive GAP: asset-sensitive | benefits from rate rise", "IRRBB: EVE + NII perspectives | 200bps stress test | EVE outlier >15% of Tier 1", "HQLA eligibility: G-Secs/T-Bills 100% | PSU bonds 85% | listed equities 50%"],
    formulaIds: ["F-BFM2", "F-BFM3", "F-BFM10", "F-BFM11"],
    topicIds: ["T-BFM-D1", "T-BFM-D2", "T-BFM-D3", "T-BFM-D4"]
  },
  {
    id: "MS-BRBL-B", moduleId: "BRBL-B", subjectId: "BRBL",
    title: "Negotiable Instruments & Banking Laws",
    bullets: [
      "NI Act 1881: cheque = NI drawn on specific banker; valid 3 months; dishonour → Sec 138 offence (imprisonment ≤2yr + fine ≤2×amount)",
      "Sec 138 timeline: dishonour → notice within 30 days → drawer pays within 15 days → complaint within 30 days of expiry",
      "Types of crossing: general, special, not-negotiable, account payee — each progressively restricts negotiability",
      "Bills of Exchange: drawer, drawee, payee; acceptance; endorsement types (blank, special, restrictive, sans recours)",
      "Banker-Customer relationship: debtor-creditor (deposits), creditor-debtor (loans), agent (collections), trustee (safe custody), bailee (locker)"
    ],
    mustRemember: ["Sec 138: notice ≤30 days of dishonour | drawer 15 days to pay | complaint ≤30 days after", "Cheque validity: 3 months from date | post-dated: valid from the date", "Account payee crossing: only credited to payee's account — most restrictive"],
    formulaIds: ["F-BRBL5"],
    topicIds: ["T-BRBL-B1", "T-BRBL-B2", "T-BRBL-B3", "T-BRBL-B4"]
  },
  {
    id: "MS-BRBL-C", moduleId: "BRBL-C", subjectId: "BRBL",
    title: "IBC, SARFAESI & Debt Recovery",
    bullets: [
      "SARFAESI 2002: non-judicial enforcement of secured loans ≥₹1 lakh | 60-day notice | residential property: DM order | excludes agriculture",
      "IBC 2016: CIRP 180 days (+90 days extension) | max 330 days | minimum default ₹1 crore | CoC = financial creditors only | Sec 53 waterfall on liquidation",
      "PPIRP (Pre-Packaged Insolvency 2021): only MSMEs | 120 days | debtor-in-possession | Swiss Challenge for competing plans",
      "RDDBFI Act 1993 / DRT: claims ≥₹20 lakh | 3-year limitation | DRAT appeal within 45 days + 75% deposit",
      "IBC Sec 53 waterfall: CIRP costs → secured FCs (1st charge) → workmen dues (2 years) → employees (12 months) → unsecured FCs → government → equity"
    ],
    mustRemember: ["SARFAESI: 60-day notice | IBC: ₹1 crore threshold | DRT: ₹20 lakh | Lok Adalat: <₹20L", "IBC CIRP max 330 days | CoC = FCs only | RP manages company | Sec 53 waterfall", "PPIRP: MSME only | 120 days | debtor stays in management | Secs 54A-54P"],
    formulaIds: ["F-BRBL1", "F-BRBL2", "F-BRBL3"],
    topicIds: ["T-BRBL-C1", "T-BRBL-C2", "T-BRBL-C3", "T-BRBL-C4"]
  },
  {
    id: "MS-Risk-A", moduleId: "Risk-A", subjectId: "Risk",
    title: "Credit Risk — Measurement & Capital",
    bullets: [
      "Credit risk = risk of borrower/counterparty default; measured via PD (probability of default), LGD (loss given default %), EAD (exposure at default ₹)",
      "Expected Loss (EL) = PD × LGD × EAD — covered by provisions; Unexpected Loss (UL) = 99.9th percentile loss − EL — covered by capital",
      "RAROC = (Risk-adjusted Return) / Economic Capital; accept deal if RAROC > cost of equity (hurdle rate ~12-15%)",
      "Basel III credit risk approaches: Standardised (external ratings/regulator-set weights) → Foundation IRB → Advanced IRB (banks estimate PD/LGD/EAD)",
      "Credit concentration: single borrower 15% of capital; group 25%; infrastructure 20%/30% — LEF (Large Exposure Framework)"
    ],
    mustRemember: ["EL = PD × LGD × EAD | EL = provisions | UL = capital", "RAROC = risk-adjusted return / economic capital | target >cost of equity", "LEF: single 15% | group 25% | infrastructure 20%/30% of capital funds"],
    formulaIds: ["F-Risk1", "F-Risk2", "F-Risk7"],
    topicIds: ["T-Risk-A1", "T-Risk-A2", "T-Risk-A3", "T-Risk-A4", "T-Risk-A5"]
  },
  {
    id: "MS-Central-B", moduleId: "Central-B", subjectId: "Central",
    title: "Monetary Policy — Operations & Instruments",
    bullets: [
      "LAF corridor: SDF (floor, Repo−25bps) → Repo Rate (key policy rate) → MSF (ceiling, Repo+25bps); corridor = 50 bps",
      "Repo: RBI lends overnight to banks against G-Sec collateral; SDF: banks park surplus with RBI (no collateral since April 2022); MSF: emergency overnight borrowing",
      "OMO (Open Market Operations): RBI buys/sells G-Secs to inject/absorb durable liquidity; G-SAP: advance OMO calendar for certainty",
      "FIT (Flexible Inflation Targeting): 4% CPI ± 2% band; 6-member MPC (3 RBI + 3 external); decisions by majority vote; quarterly projections",
      "EBLR transmission: repo cut → EBLR-linked loan rates must reset ≤3 months; ensures monetary policy reaches borrowers quickly"
    ],
    mustRemember: ["LAF corridor: SDF 5.00% | Repo 5.25% | MSF 5.50% (as of Feb 2026)", "MPC: 6 members | 4% ± 2% CPI target | quarterly projections | RBI mandate under RBI Act", "OMO: buys G-Sec = injects liquidity; sells G-Sec = absorbs liquidity"],
    formulaIds: ["F-Central7", "F-Central1", "F-Central2"],
    topicIds: ["T-Central-B1", "T-Central-B2", "T-Central-B3", "T-Central-B4", "T-Central-B5"]
  },
  {
    id: "MS-Central-E", moduleId: "Central-E", subjectId: "Central",
    title: "Bank Supervision, PCA & NBFC Regulation",
    bullets: [
      "RBS (Risk-Based Supervision) via SPARC framework since 2012; continuous, forward-looking; risk matrix = inherent risk × control effectiveness",
      "PCA triggers: CET1 <4.5% or CRAR <9% or Net NPA >6% or Leverage <3.5%; restrictions include ban on branches, dividends, concentration caps",
      "NBFC Scale-Based Regulation (Oct 2021): Base Layer (<₹1,000cr) → Middle Layer → Upper Layer (bank-equivalent norms) → Top Layer",
      "NBFC-ND-SI (≥₹500 crore): CRAR 15%, Tier 1 ≥10%, NPA 90 DPD (since 2022), board governance norms",
      "GIFT City IFSC (IFSCA Act 2019): IBUs exempt from CRR/SLR/PSL; foreign currency only; 10-yr tax holiday; GIFT Nifty futures from 2023"
    ],
    mustRemember: ["PCA: Net NPA >6% OR CET1 <4.5% OR Leverage <3.5% triggers placement", "NBFC SBR: 4 layers | Upper Layer banks = full bank-equivalent norms", "IBUs: no CRR/SLR/PSL | foreign currency | IFSCA regulates | 10-yr tax holiday"],
    formulaIds: ["F-BRBL6"],
    topicIds: ["T-Central-E1", "T-Central-E2", "T-Central-E3", "T-Central-E4", "T-Central-E5"]
  },
  {
    id: "MS-HR-B", moduleId: "HR-B", subjectId: "HR",
    title: "HRM — Recruitment, Training & Performance",
    bullets: [
      "HRM functions: acquisition (staffing), development (training/development), motivation (compensation, rewards), maintenance (retention, IR)",
      "Recruitment: job analysis → job description + job specification → sourcing → selection → onboarding; internal vs external trade-offs",
      "Training: ISD model (ADDIE — Analyse, Design, Develop, Implement, Evaluate); Kirkpatrick's 4 levels; Phillips Level 5 adds ROI",
      "Performance management: MBO (Management by Objectives); 360° feedback; balanced scorecard; KPIs and bell curve distribution",
      "HRIS (HR Information System): automates payroll, attendance, leave, recruitment; enables HR analytics for attrition, cost-per-hire predictions"
    ],
    mustRemember: ["Kirkpatrick 4 levels: Reaction → Learning → Behaviour → Results | Level 5 = ROI", "MBO: SMART objectives set jointly by manager and employee | periodic review", "360° feedback: subordinates + peers + supervisors + self-assessment"],
    formulaIds: ["F-HR4", "F-HR5"],
    topicIds: ["T-HR-B1", "T-HR-B2", "T-HR-B3", "T-HR-B4", "T-HR-B5"]
  },
  {
    id: "MS-HR-D", moduleId: "HR-D", subjectId: "HR",
    title: "Industrial Relations & Labour Codes",
    bullets: [
      "Industrial Disputes Act 1947 (now IR Code 2020): covers disputes, machinery (conciliation → arbitration → adjudication), protected workmen",
      "IR Code 2020: Standing Orders threshold raised 100→300 workers; retrenchment approval threshold 100→300; FTE = statutory recognition with same benefits",
      "Trade Union recognition: 51% → Sole Negotiating Union; <51% → Negotiating Council (unions ≥20%); 60-day notice for service condition changes",
      "Labour Codes 2019-20: 4 codes consolidate 29 laws; wages = basic+DA only; 50% rule; bonus: 8.33-20% for employees ≤₹21,000/month",
      "POSH Act 2013: ICC mandatory in every bank branch; 60-day enquiry; external member from NGO; employer liable if no ICC"
    ],
    mustRemember: ["IR Code 2020: 51% → SNU | FTE workers get same PF/ESI/Gratuity (pro-rata)", "Wage Code 2019: wages = basic+DA | 50% of CTC | bonus eligibility ≤₹21,000/month", "Gratuity = (Monthly Wages × 15/26) × Years | Max ₹20 lakh | 5 years eligibility"],
    formulaIds: ["F-HR1", "F-HR2", "F-HR3"],
    topicIds: ["T-HR-D1", "T-HR-D2", "T-HR-D3", "T-HR-D4", "T-HR-D5", "T-HR-D6", "T-HR-D7", "T-HR-D8", "T-HR-D9"]
  },
  {
    id: "MS-Rural-B", moduleId: "Rural-B", subjectId: "Rural",
    title: "Agricultural Finance — KCC, AH, Fisheries & MSME",
    bullets: [
      "KCC (Kisan Credit Card): revolving WC for crop loans; limit = Scale of Finance × Acreage + 10%; max ₹3L; effective rate 4% (2% subvention + 3% incentive)",
      "AH-KCC (extended Budget 2018): covers cattle, poultry, goat/sheep, piggery; WC for feed/fodder/vet expenses; same 4% effective rate",
      "Fisheries KCC (extended Budget 2018): WC revolving + TL for boat/nets (≤₹2L); 4% effective rate; no collateral ≤₹1.60L; PSL: Agriculture",
      "PMMSY (2020): ₹20,050 crore for fisheries; 40% subsidy general / 60% SC/ST+women; target 22 MMT fish by 2025",
      "Rural MSMEs: PMEGP (15-35% subsidy), MUDRA (Shishu/Kishore/Tarun), CGTMSE (guarantee ≤₹5 crore collateral-free)"
    ],
    mustRemember: ["KCC: 4% effective rate (2+3 subvention) | no collateral ≤₹1.60L | valid 5 years", "PMMSY: ₹20,050 crore | 60% subsidy SC/ST/women | Blue Economy target 22 MMT", "CGTMSE: 75-85% guarantee coverage for MSME loans ≤₹5 crore without collateral"],
    formulaIds: ["F-Rural1", "F-Rural4"],
    topicIds: ["T-Rural-B1", "T-Rural-B2", "T-Rural-B3", "T-Rural-B4", "T-Rural-B5", "T-Rural-B6", "T-Rural-B7"]
  },
  {
    id: "MS-Rural-C", moduleId: "Rural-C", subjectId: "Rural",
    title: "PSL, Schemes & Financial Inclusion",
    bullets: [
      "PSL: 40% ANBC for domestic SCBs | Agriculture 18% (SMF 8%) | Weaker Sections 12% | MSME 7.5% | Shortfall → RIDF at penal rates",
      "PSL Certificates (PSLCs): tradeable on CBS; 4 types (Agriculture, SM Farmers, Micro Enterprises, General); market mechanism for compliance",
      "PM-KISAN: ₹6,000/year direct income support to all farmer families (3 installments); DBT to bank accounts; Aadhaar-linked",
      "SHG-Bank Linkage: Phase I loan = 4× corpus; Phase II = 8× corpus; 10+ crore SHGs nationally linked; ₹2.5L crore outstanding",
      "PMFBY (revised 2020): voluntary for loanee farmers; 2%/1.5%/5% farmer premium (kharif/rabi/horticulture); satellites + drones for assessment"
    ],
    mustRemember: ["PSL: 40% overall | Agriculture 18% | SMF sub-target 8% | Weaker Sections 12%", "PSLCs: tradeable | prevents geographic constraint | 4 types | platform CBS", "PMFBY: voluntary (post-2020) | state can opt out | premiums unchanged | tech-enabled"],
    formulaIds: ["F-Rural2", "F-Rural3", "F-Rural4"],
    topicIds: ["T-Rural-C1", "T-Rural-C2", "T-Rural-C3", "T-Rural-C4", "T-Rural-C5", "T-Rural-C6"]
  },
  {
    id: "MS-ABFM-B", moduleId: "ABFM-B", subjectId: "ABFM",
    title: "Valuation — Capital Budgeting & Project Appraisal",
    bullets: [
      "NPV = Σ[CF_t/(1+r)^t] − Initial Investment; accept if NPV > 0; WACC is typically the discount rate",
      "IRR = discount rate making NPV = 0; accept if IRR > hurdle rate (WACC); IRR by interpolation same formula as YTM",
      "CAPM: Ke = Rf + β(Rm−Rf); β>1 more volatile; β<1 less volatile; used for cost of equity in WACC",
      "WACC = (E/V×Ke) + (D/V×Kd×(1−T)); tax shield reduces effective debt cost; used as NPV discount rate for project appraisal",
      "Gordon's Model: P₀ = D₁/(Ke−g); g = Retention Ratio × ROE; condition: Ke > g; used for bank stock valuation"
    ],
    mustRemember: ["NPV > 0 = accept | IRR > WACC = accept | conflict: use NPV for mutually exclusive projects", "WACC = weighted cost after tax shield | Ke from CAPM | Kd×(1−T)", "Gordon's: P₀ = D₁/(Ke−g) | condition Ke > g | g = b×ROE (b = retention ratio)"],
    formulaIds: ["F-ABFM1", "F-ABFM2", "F-ABFM3", "F-ABFM4", "F-ABFM6"],
    topicIds: ["T-ABFM-B1", "T-ABFM-B2", "T-ABFM-B3", "T-ABFM-B4", "T-ABFM-B5", "T-ABFM-B6"]
  },
  {
    id: "MS-IT-B", moduleId: "IT-B", subjectId: "IT",
    title: "IT Governance, Risk & Security",
    bullets: [
      "IT governance frameworks: COBIT (control objectives), ISO 27001 (information security), ITIL (service management), NIST CSF",
      "RBI IT Framework 2023: Board-approved IT strategy; CISO independent function; VAPT for internet-facing systems; patches within 7-30 days",
      "Cyber Master Directions 2024: CISO reports to Board; MFA for all transactions; device binding; 6-hour incident reporting to RBI via CIMS",
      "BCP/DR: RTO (recovery time objective) ≤2 hours for core banking; RPO (recovery point objective) ≤30 minutes; hot/warm/cold standby",
      "System availability: 99.99% target for CBS; MTBF / (MTBF + MTTR); 99.9% = 8.76 hours downtime per year"
    ],
    mustRemember: ["CISO = independent | VAPT mandatory | cyber incident report within 6 hours to RBI", "RTO ≤2 hours (core banking) | RPO ≤30 min | 99.99% availability target", "AES-256 (encryption) | TLS 1.2/1.3 (transport) | RSA-2048 (PKI minimum)"],
    formulaIds: ["F-IT1", "F-IT2", "F-IT3", "F-IT5"],
    topicIds: ["T-IT-B1", "T-IT-B2", "T-IT-B3", "T-IT-B4", "T-IT-B5"]
  },
  {
    id: "MS-Central-D", moduleId: "Central-D", subjectId: "Central",
    title: "External Sector, Forex & International Commitments",
    bullets: [
      "RBI manages forex reserves (~$700B, 2025 = ~11 months import cover); intervention tools: spot/forward market operations, currency swaps",
      "LRS (Liberalised Remittance Scheme): resident individuals can remit $250,000/year for any permissible purpose; TCS 20% on LRS >₹7L",
      "ECB policy: automatic route up to $750M for eligible sectors; RDB track; minimum average maturity requirements; end-use restrictions",
      "SDR (Special Drawing Rights): India's IMF quota ~2.75%; COVID 2021 allocation added $17.9B to India's reserves; basket: USD/EUR/CNY/JPY/GBP",
      "GIFT City IFSC (IFSCA 2019): IBUs exempt CRR/SLR/PSL; no retail INR deposits; 10-yr tax holiday; GIFT Nifty futures since 2023"
    ],
    mustRemember: ["LRS: $250,000/year | TCS 20% on >₹7 lakh | no business transactions", "SDR basket: 5 currencies | India quota ~2.75% | COVID allocation $17.9B extra reserves", "GIFT IBU: no CRR/SLR/PSL | foreign currency only | IFSCA Act 2019 | 10-yr tax holiday"],
    formulaIds: ["F-BFM12", "F-BFM14", "F-Central4", "F-Central6"],
    topicIds: ["T-Central-D1", "T-Central-D2", "T-Central-D3", "T-Central-D4", "T-Central-D5", "T-Central-D6"]
  }
];

// Helper functions for easy content queries
export function getTopicsForModule(moduleId) {
  return TOPICS[moduleId] || [];
}

export function getLessonsForSubject(subjectId) {
  return MICRO_LESSONS.filter(l => l.subjectId === subjectId);
}

export function getFormulasForSubject(subjectId) {
  return FORMULAS.filter(f => f.sub === subjectId);
}

export function getCircularsForSubject(subjectId) {
  return RBI_CIRCULARS.filter(c => c.subjectId === subjectId);
}





export function getModuleSummary(moduleId) {
  return MODULE_SUMMARIES.find(m => m.moduleId === moduleId) || null;
}

export function getModuleSummariesForSubject(subjectId) {
  return MODULE_SUMMARIES.filter(m => m.subjectId === subjectId);
}
