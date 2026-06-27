export const MICRO_LESSONS = [
  {
    id: "les_ppb_crr",
    topicId: "crr",
    subjectId: "PPB",
    title: "Cash Reserve Ratio & SLR",
    badge: "Operations",
    time: "5 min",
    emoji: "🏛️",
    steps: [
      {
        kind: "concept",
        title: "Cash Reserve Ratio (CRR)",
        body: "The percentage of demand and time deposits that banks must keep as cash reserves with the RBI. No interest is paid on these funds.",
        highlight: "CRR: 4.5% of NDTL"
      },
      {
        kind: "concept",
        title: "Statutory Liquidity Ratio (SLR)",
        body: "The mandatory proportion of deposits a bank must store in safe, liquid assets (gold, cash, approved bonds) within the bank itself.",
        highlight: "SLR: 18.0% of NDTL"
      },
      {
        kind: "pillars",
        title: "CRR vs SLR at a glance",
        pillars: [
          { n: "CRR", d: "Held in cash with the RBI · earns no interest · governed by the RBI Act, 1934" },
          { n: "SLR", d: "Held by the bank itself in cash, gold or approved securities · earns a return · governed by the Banking Regulation Act, 1949" },
          { n: "Purpose", d: "CRR is a liquidity & monetary-policy tool; SLR ensures solvency and channels funds to government securities" }
        ]
      },
      {
        kind: "scenario",
        title: "CRR & SLR Requirements",
        problem: "A commercial bank has Net Demand and Time Liabilities (NDTL) of ₹100 crore. The current Cash Reserve Ratio (CRR) is 4.5% and the Statutory Liquidity Ratio (SLR) is 18%.",
        steps: [
          "CRR = 4.5% of ₹100 Crore = ₹4.5 Crore",
          "SLR = 18.0% of ₹100 Crore = ₹18.0 Crore"
        ],
        verdict: "The bank must deposit ₹4.5 Crore with the RBI and maintain ₹18.0 Crore in liquid assets internally."
      },
      {
        kind: "concept",
        title: "Shortfall Penalty",
        body: "If a bank fails to maintain the required CRR, the RBI charges penal interest at the Bank Rate plus 3% per annum on the shortfall, rising to Bank Rate plus 5% if the shortfall continues the next day. This makes CRR compliance non-negotiable.",
        highlight: "CRR shortfall penalty: Bank Rate + 3% (then +5%)"
      },
      {
        kind: "quiz",
        question: "Where does a commercial bank keep its Cash Reserve Ratio (CRR) balance?",
        opts: ["As cash in its own vault", "With the Reserve Bank of India", "Invested in gold bullion", "Invested in corporate bonds"],
        correct: 1,
        why: "Under the RBI Act, 1934, banks are required to maintain a cash balance equivalent to the CRR percentage directly with the RBI."
      },
      {
        kind: "quiz",
        question: "Which of these assets can a bank use to meet its SLR requirement?",
        opts: ["Balances kept with the RBI as CRR", "Approved government securities and gold held by the bank", "Loans advanced to corporate borrowers", "Shares of listed private companies"],
        correct: 1,
        why: "SLR is maintained by the bank itself in cash, gold, or RBI-approved securities (mainly government securities). CRR balances cannot double-count toward SLR."
      }
    ]
  },
  {
    id: "les_ppb_kyc_aml",
    topicId: "kyc",
    subjectId: "PPB",
    title: "KYC Guidelines & Anti-Money Laundering",
    badge: "Compliance",
    time: "5 min",
    emoji: "🔍",
    steps: [
      {
        kind: "concept",
        title: "Officially Valid Documents (OVDs)",
        body: "To open accounts, customers must provide OVDs. These are: Passport, Aadhaar, Driving License, Voter ID, NREGA job card, and Letter from National Population Register.",
        highlight: "6 Officially Valid Documents"
      },
      {
        kind: "concept",
        title: "AML Stages",
        body: "Money laundering flows through three key steps: Placement (injecting cash), Layering (hiding origin), and Integration (clean funds return).",
        highlight: "Placement -> Layering -> Integration"
      },
      {
        kind: "concept",
        title: "Risk Categorisation & Periodic KYC",
        body: "Under the RBI Master Direction on KYC, banks classify customers as Low, Medium or High risk and re-verify (periodic updation) accordingly — High risk every 2 years, Medium every 8 years, and Low every 10 years.",
        highlight: "Periodic KYC: High 2y · Medium 8y · Low 10y"
      },
      {
        kind: "pillars",
        title: "Reporting to FIU-IND (under PMLA)",
        pillars: [
          { n: "CTR", d: "Cash Transaction Report — all cash transactions above ₹10 lakh in a month" },
          { n: "STR", d: "Suspicious Transaction Report — any transaction that raises a reasonable suspicion, regardless of amount" },
          { n: "CCR", d: "Counterfeit Currency Report — for forged or counterfeit notes detected" }
        ]
      },
      {
        kind: "quiz",
        question: "Which of the following is NOT an Officially Valid Document (OVD) for KYC verification?",
        opts: ["Driving License", "Aadhaar Card", "Club Membership Card", "Voter Identity Card"],
        correct: 2,
        why: "OVDs are government-issued identity documents. A club membership card is a private document and does not qualify as an OVD."
      },
      {
        kind: "quiz",
        question: "A Cash Transaction Report (CTR) must be filed with FIU-IND for cash transactions exceeding what threshold in a month?",
        opts: ["₹50,000", "₹1 lakh", "₹10 lakh", "₹50 lakh"],
        correct: 2,
        why: "Under the PMLA rules, banks report all cash transactions of more than ₹10 lakh (or equivalent in foreign currency) in a month via the CTR."
      }
    ]
  },
  {
    id: "les_ieifs_monetary_policy",
    topicId: "monetary_policy",
    subjectId: "IEIFS",
    title: "Monetary Policy & Inflation",
    badge: "Economy",
    time: "5 min",
    emoji: "📈",
    steps: [
      {
        kind: "concept",
        title: "Policy Repo Rate",
        body: "The interest rate at which the RBI lends money to commercial banks. Raising Repo Rate helps control inflation by making borrowing costlier.",
        highlight: "Repo Rate: Primary lending rate of RBI"
      },
      {
        kind: "concept",
        title: "Consumer Price Index (CPI)",
        body: "Tracks retail inflation by measuring price changes of a basket of goods and services consumed by retail buyers. CPI is the RBI's primary anchor.",
        highlight: "CPI Combined: Retail Inflation Anchor"
      },
      {
        kind: "pillars",
        title: "The RBI's quantitative tools",
        pillars: [
          { n: "Repo Rate", d: "Rate at which the RBI lends to banks against securities (short term)" },
          { n: "Reverse Repo", d: "Rate at which the RBI absorbs liquidity by borrowing from banks" },
          { n: "MSF", d: "Marginal Standing Facility — emergency overnight borrowing, above the repo rate" },
          { n: "CRR / SLR", d: "Reserve ratios that directly tighten or loosen lendable funds" }
        ]
      },
      {
        kind: "concept",
        title: "Flexible Inflation Targeting",
        body: "Since 2016 the RBI follows a flexible inflation-targeting framework. The Government, in consultation with the RBI, sets a CPI target of 4% with a tolerance band of +/- 2% (i.e. 2%-6%). The six-member Monetary Policy Committee (MPC) decides the policy rate.",
        highlight: "CPI target: 4% (+/- 2%) · set by the MPC"
      },
      {
        kind: "quiz",
        question: "When the Reserve Bank of India (RBI) raises the Repo Rate, what is the expected impact on the banking system?",
        opts: [
          "Lending to commercial banks becomes cheaper",
          "Lending rates for retail consumers decrease",
          "Cost of borrowing for commercial banks increases, leading to higher consumer lending rates",
          "Money supply in the economy increases rapidly"
        ],
        correct: 2,
        why: "Repo rate is the rate at which the RBI lends money to commercial banks. Raising it increases the cost of funds for banks, which they pass on to consumers by raising interest rates."
      },
      {
        kind: "quiz",
        question: "How many members does the Monetary Policy Committee (MPC) of the RBI have?",
        opts: ["Three", "Four", "Six", "Twelve"],
        correct: 2,
        why: "The MPC has six members — three from the RBI (including the Governor, who has a casting vote) and three appointed by the Government — and it sets the policy repo rate to meet the inflation target."
      }
    ]
  },
  {
    id: "les_rbwm_products",
    topicId: "banking_products",
    subjectId: "RBWM",
    title: "Retail Banking Products & Credit",
    badge: "Retail",
    time: "5 min",
    emoji: "💳",
    steps: [
      {
        kind: "concept",
        title: "Asset vs Liability Products",
        body: "Asset products are loans provided to customers (Home, Auto). Liability products are deposit accounts (Savings, Fixed).",
        highlight: "Assets = Loans | Liabilities = Deposits"
      },
      {
        kind: "concept",
        title: "Credit Score (CIBIL)",
        body: "A 3-digit numeric summary of a consumer's credit history, ranging from 300 to 900. A score of 750+ is generally considered good and improves loan approval odds and pricing. India has four RBI-licensed credit bureaus: CIBIL, Equifax, Experian and CRIF High Mark.",
        highlight: "Score range 300-900 · 750+ is good"
      },
      {
        kind: "pillars",
        title: "Common retail products",
        pillars: [
          { n: "Liability", d: "Savings, Current, Fixed and Recurring Deposits" },
          { n: "Asset (secured)", d: "Home loan, auto loan, loan against property/securities" },
          { n: "Asset (unsecured)", d: "Personal loan, credit card, education loan" }
        ]
      },
      {
        kind: "quiz",
        question: "Which of the following is classified as a retail bank asset product?",
        opts: ["Savings Bank Account", "Fixed Deposit Scheme", "Home Loan Account", "Current Account"],
        correct: 2,
        why: "Asset products are products where the bank lends money to customer borrowers, generating interest income."
      },
      {
        kind: "quiz",
        question: "A CIBIL credit score can range between which values?",
        opts: ["0 to 100", "300 to 900", "1 to 1000", "500 to 850"],
        correct: 1,
        why: "The CIBIL score ranges from 300 to 900; a higher score indicates stronger creditworthiness, with 750 and above generally treated as good."
      }
    ]
  },
  {
    id: "les_afm_time_value",
    topicId: "time_value_of_money",
    subjectId: "AFM",
    title: "Time Value of Money & Depreciation",
    badge: "Accounting",
    time: "5 min",
    emoji: "🧮",
    steps: [
      {
        kind: "concept",
        title: "Compounding and Discounting",
        body: "Future Value (FV) compound a present sum. Present Value (PV) discounts a future sum.",
        highlight: "FV = PV * (1 + r)^n"
      },
      {
        kind: "concept",
        title: "Depreciation",
        body: "Straight Line Method (SLM) charges constant depreciation annually. Written Down Value (WDV) applies a fixed rate to beginning book value.",
        highlight: "SLM = (Cost - Scrap) / Life"
      },
      {
        kind: "quiz",
        question: "Calculate the Present Value of ₹121 received 2 years from now, discounted at an annual interest rate of 10% (in ₹).",
        opts: ["₹90", "₹100", "₹110", "₹120"],
        correct: 1,
        why: "Using PV formula: PV = FV / (1 + r)^n. PV = 121 / (1 + 0.10)^2 = 121 / 1.21 = ₹100."
      }
    ]
  },
  {
    id: "les_ieifs_gdp",
    topicId: "gdp",
    subjectId: "IEIFS",
    title: "GDP Concepts & National Income",
    badge: "Economy",
    time: "5 min",
    emoji: "🌍",
    steps: [
      {
        kind: "concept",
        title: "Gross Domestic Product (GDP)",
        body: "The total market value of all finished goods and services produced within a country's borders in a specific time period.",
        highlight: "GDP = C + I + G + (X - M)"
      },
      {
        kind: "concept",
        title: "Real vs Nominal GDP",
        body: "Nominal GDP is evaluated at current market prices. Real GDP is adjusted for inflation by using a base year's prices.",
        highlight: "Real GDP = Nominal GDP / GDP Deflator"
      },
      {
        kind: "pillars",
        title: "Related aggregates",
        pillars: [
          { n: "GDP vs GNP", d: "GNP = GDP + net factor income from abroad" },
          { n: "GVA", d: "Gross Value Added = GDP - (taxes - subsidies) on products; India's preferred supply-side measure" },
          { n: "NDP / NNP", d: "Subtract depreciation from GDP / GNP to get the 'net' figures" }
        ]
      },
      {
        kind: "concept",
        title: "Who measures it",
        body: "In India, GDP estimates are compiled by the National Statistical Office (NSO) under the Ministry of Statistics and Programme Implementation (MoSPI). The current base year for the national accounts series is 2011-12.",
        highlight: "GDP compiled by NSO/MoSPI · base year 2011-12"
      },
      {
        kind: "quiz",
        question: "If a country's Nominal GDP is ₹120 Crore and the GDP Deflator is 120 (or 1.20), what is its Real GDP?",
        opts: ["₹100 Crore", "₹110 Crore", "₹120 Crore", "₹144 Crore"],
        correct: 0,
        why: "Real GDP = Nominal GDP / GDP Deflator (expressed as decimal) = 120 / 1.20 = ₹100 Crore."
      },
      {
        kind: "quiz",
        question: "Gross National Product (GNP) differs from Gross Domestic Product (GDP) by which factor?",
        opts: ["Depreciation", "Net factor income from abroad", "Indirect taxes", "Subsidies"],
        correct: 1,
        why: "GNP = GDP + Net Factor Income from Abroad (income earned by residents abroad minus income earned by foreigners domestically)."
      }
    ]
  },
  {
    id: "les_ieifs_regulators",
    topicId: "financial_regulators",
    subjectId: "IEIFS",
    title: "Financial Market Regulators",
    badge: "Regulation",
    time: "4 min",
    emoji: "⚖️",
    steps: [
      {
        kind: "concept",
        title: "Regulatory Domains",
        body: "India's financial system is supervised by distinct statutory bodies: RBI (banking, currency, debt markets), SEBI (securities/capital markets), IRDAI (insurance), and PFRDA (pensions).",
        highlight: "RBI, SEBI, IRDAI, PFRDA"
      },
      {
        kind: "pillars",
        title: "Who regulates what",
        pillars: [
          { n: "RBI", d: "Banks, NBFCs, currency, monetary policy, payment systems, government debt" },
          { n: "SEBI", d: "Stock exchanges, mutual funds, brokers, listed companies" },
          { n: "IRDAI", d: "Life and general insurance companies and intermediaries" },
          { n: "PFRDA", d: "National Pension System and pension funds" }
        ]
      },
      {
        kind: "concept",
        title: "Coordination & Deposit Insurance",
        body: "The Financial Stability and Development Council (FSDC), chaired by the Finance Minister, coordinates across regulators. Bank deposits are insured by the DICGC (a RBI subsidiary) up to ₹5 lakh per depositor per bank.",
        highlight: "FSDC coordinates · DICGC insures deposits up to ₹5 lakh"
      },
      {
        kind: "quiz",
        question: "Which regulator supervises and regulates the functioning of Mutual Funds in India?",
        opts: ["Reserve Bank of India (RBI)", "Securities and Exchange Board of India (SEBI)", "Insurance Regulatory and Development Authority (IRDAI)", "Pension Fund Regulatory and Development Authority (PFRDA)"],
        correct: 1,
        why: "SEBI regulates the securities markets, including asset management companies and mutual funds in India."
      },
      {
        kind: "quiz",
        question: "Up to what amount per depositor per bank are bank deposits insured by the DICGC?",
        opts: ["₹1 lakh", "₹2 lakh", "₹5 lakh", "₹10 lakh"],
        correct: 2,
        why: "The Deposit Insurance and Credit Guarantee Corporation (DICGC), a subsidiary of the RBI, insures deposits up to ₹5 lakh per depositor per bank, covering principal and interest."
      }
    ]
  },
  {
    id: "les_ppb_psl",
    topicId: "priority_sector_lending",
    subjectId: "PPB",
    title: "Priority Sector Lending (PSL)",
    badge: "Regulations",
    time: "6 min",
    emoji: "🌾",
    steps: [
      {
        kind: "concept",
        title: "Priority Sector Targets",
        body: "Domestic commercial banks are mandated to direct 40% of Adjusted Net Bank Credit (ANBC) — or the credit-equivalent of off-balance-sheet exposure, whichever is higher — to priority sectors.",
        highlight: "PSL Target: 40% of ANBC"
      },
      {
        kind: "pillars",
        title: "Eligible Priority Sectors",
        pillars: [
          { n: "Agriculture", d: "Farm credit, agri-infrastructure and ancillary activities · sub-target 18% of ANBC" },
          { n: "MSME", d: "Micro, small and medium enterprises" },
          { n: "Others", d: "Education, Housing, Social Infrastructure, Renewable Energy, and credit to weaker sections" }
        ]
      },
      {
        kind: "concept",
        title: "Sub-targets",
        body: "Within the 40% umbrella the RBI sets sub-targets: 18% of ANBC for Agriculture (with a carve-out for small & marginal farmers) and 7.5% for Micro Enterprises. Weaker sections carry a 12% sub-target.",
        highlight: "Agri 18% · Micro Enterprises 7.5% · Weaker Sections 12%"
      },
      {
        kind: "concept",
        title: "Shortfall & RIDF",
        body: "Banks that fall short of PSL targets must contribute the shortfall to the Rural Infrastructure Development Fund (RIDF) maintained with NABARD, or other funds specified by the RBI. PSL targets can also be met by buying Priority Sector Lending Certificates (PSLCs).",
        highlight: "Shortfall -> RIDF (NABARD) · trade via PSLCs"
      },
      {
        kind: "quiz",
        question: "What is the overall Priority Sector Lending (PSL) target for domestic scheduled commercial banks in India?",
        opts: ["32% of ANBC", "40% of ANBC", "18% of ANBC", "7.5% of ANBC"],
        correct: 1,
        why: "Domestic Scheduled Commercial Banks and Foreign Banks with 20 or more branches must allocate 40% of ANBC or Credit Equivalent Amount of Off-Balance Sheet Exposure, whichever is higher, to priority sectors."
      },
      {
        kind: "quiz",
        question: "What is the sub-target prescribed for lending to the Agriculture sector?",
        opts: ["10% of ANBC", "18% of ANBC", "7.5% of ANBC", "40% of ANBC"],
        correct: 1,
        why: "Within the 40% PSL target, a sub-target of 18% of ANBC is prescribed for Agriculture, including a dedicated allocation for small and marginal farmers."
      }
    ]
  },
  {
    id: "les_ppb_payment_systems",
    topicId: "payment_systems",
    subjectId: "PPB",
    title: "Digital Payment Systems",
    badge: "Technology",
    time: "6 min",
    emoji: "⚡",
    steps: [
      {
        kind: "concept",
        title: "NEFT vs RTGS",
        body: "NEFT settles in half-hourly batches and has no minimum or maximum amount. RTGS processes transactions in real time, order-by-order, and is meant for high-value payments. Both are operated by the RBI and run 24x7x365.",
        highlight: "RTGS Minimum: ₹2 Lakh · NEFT: no limit"
      },
      {
        kind: "pillars",
        title: "Four rails you must know",
        pillars: [
          { n: "RTGS", d: "Real-time, gross (one-by-one), high value · min ₹2 lakh · RBI-operated" },
          { n: "NEFT", d: "Deferred net settlement in half-hourly batches · any amount · RBI-operated" },
          { n: "IMPS", d: "Instant 24x7 mobile/inter-bank transfer · operated by NPCI · per-txn limit ₹5 lakh" },
          { n: "UPI", d: "Instant mobile payments via Virtual Payment Address · operated by NPCI · typical limit ₹1 lakh (higher for some categories)" }
        ]
      },
      {
        kind: "concept",
        title: "Who operates what",
        body: "The RBI directly operates RTGS and NEFT. The National Payments Corporation of India (NPCI) — an umbrella organisation — operates IMPS, UPI, RuPay, AePS, NACH and the Cheque Truncation System (CTS).",
        highlight: "RBI: RTGS, NEFT · NPCI: IMPS, UPI, RuPay, CTS"
      },
      {
        kind: "quiz",
        question: "What is the minimum transaction limit for retail fund transfers via Real Time Gross Settlement (RTGS)?",
        opts: ["No minimum limit", "₹50,000", "₹1 Lakh", "₹2 Lakh"],
        correct: 3,
        why: "RTGS is meant for high-value settlement. The minimum amount for transferring funds via RTGS is ₹2 Lakh, with no maximum ceiling."
      },
      {
        kind: "quiz",
        question: "Which organisation operates the Unified Payments Interface (UPI) and IMPS?",
        opts: ["Reserve Bank of India", "National Payments Corporation of India (NPCI)", "SEBI", "Indian Banks' Association"],
        correct: 1,
        why: "UPI, IMPS, RuPay and the Cheque Truncation System are operated by NPCI, while the RBI itself operates RTGS and NEFT."
      }
    ]
  },
  {
    id: "les_afm_capital_budgeting",
    topicId: "time_value_of_money",
    subjectId: "AFM",
    title: "Capital Budgeting (NPV & IRR)",
    badge: "Finance",
    time: "5 min",
    emoji: "💰",
    steps: [
      {
        kind: "concept",
        title: "Net Present Value (NPV)",
        body: "The difference between the present value of cash inflows and the present value of cash outflows over a period of time. A project with positive NPV is accepted.",
        highlight: "Accept project if NPV > 0"
      },
      {
        kind: "quiz",
        question: "If a project has an initial outflow of ₹1,000 and the present value of its future cash inflows is ₹1,200, what is its NPV?",
        opts: ["-₹200", "₹200", "₹1,000", "₹1,200"],
        correct: 1,
        why: "NPV = Present Value of Inflows - Initial Outflow = 1,200 - 1,000 = ₹200."
      }
    ]
  },
  {
    id: "les_afm_accounting_cycle",
    topicId: "balance_sheet",
    subjectId: "AFM",
    title: "The Accounting Equation",
    badge: "Accounting",
    time: "5 min",
    emoji: "📖",
    steps: [
      {
        kind: "concept",
        title: "Balance Sheet Identity",
        body: "The fundamental accounting equation states that a firm's total assets must equal the sum of its liabilities and owner's equity.",
        highlight: "Assets = Liabilities + Equity"
      },
      {
        kind: "quiz",
        question: "If a business has Assets of ₹50,000 and Liabilities of ₹20,000, what is its Owner's Equity?",
        opts: ["₹20,000", "₹30,000", "₹50,000", "₹70,000"],
        correct: 1,
        why: "Equity = Assets - Liabilities = 50,000 - 20,000 = ₹30,000."
      }
    ]
  },
  {
    id: "les_rbwm_recovery",
    topicId: "credit_scoring",
    subjectId: "RBWM",
    title: "Debt Recovery Channels",
    badge: "Recovery",
    time: "5 min",
    emoji: "⚖️",
    steps: [
      {
        kind: "concept",
        title: "SARFAESI & Lok Adalats",
        body: "The SARFAESI Act, 2002 allows secured creditors to enforce security and recover dues without court intervention, but only for secured loans where the outstanding is above ₹1 lakh and the account is an NPA. Lok Adalats resolve smaller disputes through compromise settlements.",
        highlight: "SARFAESI: secured NPAs > ₹1 lakh, no court needed"
      },
      {
        kind: "pillars",
        title: "Recovery channels",
        pillars: [
          { n: "SARFAESI", d: "Seize/sell secured assets without court (secured NPAs)" },
          { n: "DRT", d: "Debt Recovery Tribunal for bank dues of ₹20 lakh and above" },
          { n: "Lok Adalat", d: "Compromise settlement for cases up to ₹20 lakh" },
          { n: "IBC", d: "Insolvency & Bankruptcy Code for corporate insolvency resolution" }
        ]
      },
      {
        kind: "quiz",
        question: "What is the maximum monetary limit for cases referred to Lok Adalats for debt recovery settlement?",
        opts: ["₹5 Lakh", "₹10 Lakh", "₹20 Lakh", "No limit"],
        correct: 2,
        why: "Banks refer cases with outstanding balances up to ₹20 Lakh to Lok Adalats for recovery through compromise settlement."
      },
      {
        kind: "quiz",
        question: "Recovery of bank dues through a Debt Recovery Tribunal (DRT) is available for amounts of:",
        opts: ["₹1 lakh and above", "₹10 lakh and above", "₹20 lakh and above", "Any amount"],
        correct: 2,
        why: "DRTs, set up under the RDDBFI Act, adjudicate bank and financial-institution recovery cases where the amount of debt due is ₹20 lakh or more."
      }
    ]
  },
  {
    id: "les_rbwm_marketing",
    topicId: "marketing",
    subjectId: "RBWM",
    title: "Marketing Mix in Banking",
    badge: "Marketing",
    time: "4 min",
    emoji: "📢",
    steps: [
      {
        kind: "concept",
        title: "The 7 Ps",
        body: "Service marketing expands the 4 Ps (Product, Price, Place, Promotion) to include: People (staff), Process (delivery systems), and Physical Evidence (ambience, digital portals).",
        highlight: "7 Ps of Service Marketing"
      },
      {
        kind: "concept",
        title: "Service Characteristics",
        body: "Banking services are distinct from goods on four counts: Intangibility (can't be touched), Inseparability (produced and consumed together), Perishability (can't be stored), and Variability/Heterogeneity (quality varies by who delivers it).",
        highlight: "Intangible · Inseparable · Perishable · Variable"
      },
      {
        kind: "concept",
        title: "Cross-selling vs Up-selling",
        body: "Cross-selling offers a different, complementary product to an existing customer (e.g. insurance to a deposit holder). Up-selling persuades a customer to upgrade to a higher-value version of the same product. Both raise revenue per customer but must respect suitability.",
        highlight: "Cross-sell = different product · Up-sell = higher version"
      },
      {
        kind: "quiz",
        question: "Which of the following represents 'Physical Evidence' in the retail banking marketing mix?",
        opts: ["Interest rates on loans", "Friendly bank tellers", "A clean, modern bank branch lobby or intuitive mobile app", "Direct mail advertisements"],
        correct: 2,
        why: "Physical Evidence is the environment in which the service is delivered and where the firm and customer interact, such as branch ambience or app interfaces."
      },
      {
        kind: "quiz",
        question: "Offering a home-loan customer a linked home-insurance policy is an example of:",
        opts: ["Up-selling", "Cross-selling", "Down-selling", "De-marketing"],
        correct: 1,
        why: "Selling a different but complementary product (insurance) to an existing customer (home-loan borrower) is cross-selling."
      }
    ]
  },
  {
    id: "les_ppb_banker_rights",
    topicId: "banker_customer_rights",
    subjectId: "PPB",
    title: "Banker's Special Rights",
    badge: "Operations",
    time: "5 min",
    emoji: "📜",
    steps: [
      {
        kind: "concept",
        title: "Lien & Set-off",
        body: "Banker's Lien is an implied pledge giving the bank the right to retain securities/goods for a general balance of account. Right of Set-off enables the bank to combine two or more accounts of the same customer (held in the same capacity) to settle a debt.",
        highlight: "Lien: Right to retain | Set-off: Right to combine accounts"
      },
      {
        kind: "concept",
        title: "Right of Appropriation (Clayton's Rule)",
        body: "When a customer owes several debts and pays in money, the customer may appropriate it to a specific debt. If they don't, the banker may appropriate. For a running account, Clayton's Rule applies: the first item on the debit side is discharged by the first item on the credit side ('first in, first out').",
        highlight: "Clayton's Rule: first credit clears the first debit"
      },
      {
        kind: "concept",
        title: "Garnishee Order",
        body: "A Garnishee Order is issued by a court attaching a customer's balance to satisfy a creditor. It comes in two stages: Order Nisi (freezes the account) and Order Absolute (directs the bank to pay). It does not attach amounts not yet due or accounts held in a different capacity.",
        highlight: "Order Nisi (freeze) -> Order Absolute (pay)"
      },
      {
        kind: "quiz",
        question: "Under what legal concept can a bank combine a customer's credit balance in one account with a debit balance in another to recover overdue debt?",
        opts: ["Right of Appropriation", "Right of Lien", "Right of Set-off", "Right of Pledge"],
        correct: 2,
        why: "The Right of Set-off is the statutory right of a banker to combine two accounts of the same debtor/creditor capacity to adjust a debt."
      },
      {
        kind: "quiz",
        question: "The first stage of a Garnishee Order, which freezes the customer's account, is known as:",
        opts: ["Order Absolute", "Order Nisi", "Order of Attachment", "Order of Lien"],
        correct: 1,
        why: "A Garnishee Order is issued in two parts — Order Nisi freezes the balance, and Order Absolute directs the bank to pay the attached amount to the court/creditor."
      }
    ]
  },
  {
    id: "les_ppb_collaterals",
    topicId: "collateral_types",
    subjectId: "PPB",
    title: "Collateral Charges: Pledge vs Mortgage",
    badge: "Credit",
    time: "5 min",
    emoji: "🔑",
    steps: [
      {
        kind: "pillars",
        title: "Four ways to charge a security",
        pillars: [
          { n: "Pledge", d: "Movable goods; possession with the bank (e.g. gold loan). Governed by the Indian Contract Act." },
          { n: "Hypothecation", d: "Movable assets; possession stays with the borrower (e.g. vehicle/stock loan)." },
          { n: "Mortgage", d: "Immovable property (land, buildings). Governed by the Transfer of Property Act." },
          { n: "Assignment", d: "Transfer of an actionable claim such as a life-insurance policy or book debts." }
        ]
      },
      {
        kind: "concept",
        title: "Types of Mortgage",
        body: "Common forms include the Simple Mortgage, the Equitable Mortgage (created by deposit of title deeds — quick and popular for housing loans), the Registered/English Mortgage, and the Usufructuary Mortgage. The Equitable Mortgage needs no registration in notified towns, making it cost-effective.",
        highlight: "Equitable Mortgage = deposit of title deeds (no registration)"
      },
      {
        kind: "quiz",
        question: "When a bank extends a loan against gold ornaments and takes physical custody of the gold, what type of charge is created?",
        opts: ["Hypothecation", "Mortgage", "Pledge", "Lien"],
        correct: 2,
        why: "A pledge involves bailment (transfer of possession) of movable goods to the creditor bank as security for a loan."
      },
      {
        kind: "quiz",
        question: "A mortgage created by depositing the title deeds of an immovable property with the lender is called a:",
        opts: ["Simple Mortgage", "Equitable Mortgage", "English Mortgage", "Usufructuary Mortgage"],
        correct: 1,
        why: "An Equitable Mortgage (mortgage by deposit of title deeds) is created when the borrower hands over title documents as security; it requires no registration in notified towns and is widely used for housing loans."
      }
    ]
  },
  {
    id: "les_ieifs_money_market",
    topicId: "money_market",
    subjectId: "IEIFS",
    title: "Money Market Instruments",
    badge: "Financial Markets",
    time: "5 min",
    emoji: "💵",
    steps: [
      {
        kind: "concept",
        title: "Call Money & Commercial Paper",
        body: "- **Call Money**: Inter-bank borrowing/lending for 1 day.\n- **Notice Money**: Borrowing/lending for 2 to 14 days.\n- **Commercial Paper (CP)**: Unsecured promissory note issued by corporates. Min value: ₹5 Lakh.\n- **Treasury Bills (T-Bills)**: Short-term debt issued by RBI on behalf of Government (91, 182, 364 days).",
        highlight: "Call: 1 day | Notice: 2-14 days | CP Min: ₹5 Lakh"
      },
      {
        kind: "concept",
        title: "Money Market vs Capital Market",
        body: "The money market deals in short-term funds (up to 1 year) — high liquidity, low risk. The capital market deals in long-term funds (over 1 year) through equity and debt instruments. T-Bills carry no coupon; they are issued at a discount and redeemed at face value.",
        highlight: "Money market: < 1 year | Capital market: > 1 year"
      },
      {
        kind: "concept",
        title: "Certificate of Deposit (CD)",
        body: "A CD is a negotiable money-market instrument issued by banks against funds deposited for a fixed period. Unlike a fixed deposit, a CD is transferable. Minimum issue size is ₹5 lakh.",
        highlight: "CD: bank-issued, negotiable · min ₹5 lakh"
      },
      {
        kind: "quiz",
        question: "What is the term used for inter-bank fund borrowing/lending for a period of exactly one day?",
        opts: ["Notice Money", "Term Money", "Call Money", "Commercial Paper"],
        correct: 2,
        why: "Funds borrowed or lent in the inter-bank market for one day are termed Call Money. If for 2 to 14 days, it is called Notice Money."
      },
      {
        kind: "quiz",
        question: "Treasury Bills (T-Bills) issued by the RBI are available in which maturities?",
        opts: ["91, 182 and 364 days", "1, 5 and 10 years", "30 and 60 days", "1 and 2 years"],
        correct: 0,
        why: "T-Bills are short-term government securities issued in three tenors — 91-day, 182-day and 364-day — at a discount to face value, with no separate interest coupon."
      }
    ]
  },
  {
    id: "les_afm_ratio_analysis",
    topicId: "ratio_analysis",
    subjectId: "AFM",
    title: "Financial Ratio Analysis",
    badge: "Numerical",
    time: "5 min",
    emoji: "📊",
    steps: [
      {
        kind: "concept",
        title: "Liquidity Ratios",
        body: "Current Ratio evaluates the firm's capacity to pay off short-term debt.\nQuick Ratio (Acid Test) excludes inventory from current assets to test immediate liquidity.",
        highlight: "Current Ratio = Current Assets / Current Liabilities"
      },
      {
        kind: "concept",
        title: "Quick Ratio Formula",
        body: "Quick Assets are Current Assets excluding Inventory and Prepaid Expenses.",
        highlight: "Quick Ratio = (Current Assets - Inventory) / Current Liabilities"
      },
      {
        kind: "quiz",
        question: "Calculate the Current Ratio of a firm with Current Assets of ₹1,00,000, Current Liabilities of ₹50,000, and Inventory of ₹20,000.",
        opts: ["1.6:1", "2.0:1", "2.5:1", "3.0:1"],
        correct: 1,
        why: "Current Ratio = Current Assets / Current Liabilities = 1,00,000 / 50,000 = 2.0:1."
      }
    ]
  },
  {
    id: "les_rbwm_npa",
    topicId: "npa_classification",
    subjectId: "RBWM",
    title: "NPA Asset Classification",
    badge: "Recovery",
    time: "5 min",
    emoji: "⚠️",
    steps: [
      {
        kind: "concept",
        title: "Asset Categories",
        body: "An account becomes a Non-Performing Asset (NPA) if interest/installment remains overdue for more than 90 days. NPAs are classified as:\n- **Substandard**: NPA for ≤ 12 months.\n- **Doubtful**: NPA for > 12 months.\n- **Loss Assets**: Identified as uncollectible by the bank or auditor.",
        highlight: "NPA trigger: > 90 days overdue"
      },
      {
        kind: "concept",
        title: "SMA Early-Warning Categories",
        body: "Before becoming an NPA, an account is flagged as a Special Mention Account (SMA): SMA-0 (overdue 1-30 days), SMA-1 (31-60 days), and SMA-2 (61-90 days). These early-warning buckets help banks act before the 90-day NPA threshold.",
        highlight: "SMA-0: 1-30d · SMA-1: 31-60d · SMA-2: 61-90d"
      },
      {
        kind: "concept",
        title: "Provisioning",
        body: "Banks must set aside provisions against NPAs from profits: roughly 15% for secured sub-standard assets, rising for doubtful assets by age, and 100% for loss assets. Provisioning protects the bank's balance sheet against expected loss.",
        highlight: "Provisioning rises with the age/severity of the NPA"
      },
      {
        kind: "quiz",
        question: "After what period of remaining in the Non-Performing Asset (NPA) category is an asset classified as a 'Doubtful Asset'?",
        opts: ["6 months", "12 months", "18 months", "24 months"],
        correct: 1,
        why: "An asset is classified as substandard if it remains an NPA for up to 12 months, after which it transitions to the doubtful category."
      },
      {
        kind: "quiz",
        question: "An account where principal/interest is overdue between 61 and 90 days is flagged as:",
        opts: ["SMA-0", "SMA-1", "SMA-2", "Substandard NPA"],
        correct: 2,
        why: "SMA-2 covers overdues of 61-90 days. Beyond 90 days the account is classified as an NPA (initially substandard)."
      }
    ]
  },
  {
    id: "les_ppb_banker_customer",
    topicId: "banker_customer_relationship",
    subjectId: "PPB",
    title: "Banker-Customer Relationship",
    badge: "Operations",
    time: "6 min",
    emoji: "🤝",
    steps: [
      {
        kind: "concept",
        title: "The Core Relationship",
        body: "When a customer deposits money, the bank becomes the debtor and the customer the creditor — the bank owns the money and owes a debt. For a loan, the roles reverse. The relationship is established once an account is opened and accepted.",
        highlight: "Deposit: Bank = Debtor · Loan: Bank = Creditor"
      },
      {
        kind: "pillars",
        title: "Relationships by service",
        pillars: [
          { n: "Debtor / Creditor", d: "Ordinary deposits and loans" },
          { n: "Bailor / Bailee", d: "Safe custody of articles and lockers" },
          { n: "Principal / Agent", d: "Collecting cheques, paying bills on standing instruction" },
          { n: "Trustee / Beneficiary", d: "Funds held for a specific named purpose" }
        ]
      },
      {
        kind: "concept",
        title: "Banker's Obligations",
        body: "The banker owes a duty to honour cheques when funds are available, to maintain secrecy of the customer's account (except under RBI/legal/public-duty exceptions), and to give reasonable notice before closing an account.",
        highlight: "Duty: honour cheques · maintain secrecy · give notice"
      },
      {
        kind: "quiz",
        question: "In an ordinary savings deposit, what is the legal relationship between the bank and the customer?",
        opts: ["Bailor and Bailee", "Bank is debtor, customer is creditor", "Trustee and Beneficiary", "Principal and Agent"],
        correct: 1,
        why: "On a deposit the bank owns the money and is liable to repay it, making the bank the debtor and the depositing customer the creditor."
      },
      {
        kind: "quiz",
        question: "When a customer keeps valuables in a bank's safe custody, the relationship is that of:",
        opts: ["Debtor and Creditor", "Bailor and Bailee", "Mortgagor and Mortgagee", "Lessor and Lessee"],
        correct: 1,
        why: "Safe custody is a bailment — the customer (bailor) hands goods to the bank (bailee), which must take reasonable care and return them."
      }
    ]
  },
  {
    id: "les_ppb_customer_accounts",
    topicId: "types_of_accounts",
    subjectId: "PPB",
    title: "Types of Customers & Accounts",
    badge: "Operations",
    time: "6 min",
    emoji: "👥",
    steps: [
      {
        kind: "concept",
        title: "Special Customers",
        body: "Certain customers need special handling: a Minor (under 18) can open an account but the bank generally avoids overdrafts; a partnership account is opened in the firm's name; a company account needs the Board resolution and Memorandum/Articles of Association.",
        highlight: "Minor: no overdraft · Company: Board resolution required"
      },
      {
        kind: "pillars",
        title: "Joint account operation",
        pillars: [
          { n: "Either or Survivor", d: "Either holder operates; on death of one, the survivor continues" },
          { n: "Former or Survivor", d: "Only the first holder operates while alive" },
          { n: "Jointly", d: "All holders must sign for every transaction" }
        ]
      },
      {
        kind: "concept",
        title: "Nomination & Deceased Accounts",
        body: "A depositor may nominate one person to receive the balance on death. The nominee is a trustee for the legal heirs, not the owner. For 'Either or Survivor' accounts the balance passes to the survivor; nomination simplifies settlement and avoids succession-certificate delays.",
        highlight: "Nominee = trustee for legal heirs, not the owner"
      },
      {
        kind: "quiz",
        question: "In an 'Either or Survivor' joint account, who can operate the account during the lifetime of both holders?",
        opts: ["Only the first-named holder", "Either of the two holders", "Both holders jointly only", "Only with bank manager approval"],
        correct: 1,
        why: "Under 'Either or Survivor', either holder can independently operate the account, and on the death of one the survivor can continue to operate it."
      },
      {
        kind: "quiz",
        question: "What is the legal status of a nominee in a deposit account?",
        opts: ["The absolute owner of the funds", "A trustee for the legal heirs", "A guarantor for the deposit", "An authorised signatory only"],
        correct: 1,
        why: "A nominee merely receives the funds on the depositor's death and holds them as a trustee on behalf of the legal heirs; ownership is decided by succession law."
      }
    ]
  },
  {
    id: "les_ppb_negotiable_instruments",
    topicId: "negotiable_instruments",
    subjectId: "PPB",
    title: "Negotiable Instruments",
    badge: "Compliance",
    time: "7 min",
    emoji: "🧾",
    steps: [
      {
        kind: "concept",
        title: "What is a Negotiable Instrument?",
        body: "Governed by the Negotiable Instruments Act, 1881, a negotiable instrument is a document guaranteeing payment of a specific amount, transferable by delivery or endorsement. The three statutory types are the Promissory Note, the Bill of Exchange, and the Cheque.",
        highlight: "NI Act, 1881 · Promissory Note, Bill of Exchange, Cheque"
      },
      {
        kind: "pillars",
        title: "The three instruments",
        pillars: [
          { n: "Promissory Note", d: "An unconditional promise by the maker to pay the payee (2 parties)" },
          { n: "Bill of Exchange", d: "An unconditional order by the drawer to the drawee to pay the payee (3 parties)" },
          { n: "Cheque", d: "A bill of exchange drawn on a specified bank, payable on demand" }
        ]
      },
      {
        kind: "concept",
        title: "Crossing of Cheques",
        body: "A General Crossing (two parallel lines) means the cheque must be paid into a bank account, not over the counter. A Special Crossing names a specific bank. 'Account Payee' crossing restricts collection to the named payee's account, adding safety.",
        highlight: "Crossing -> pay into account only (not cash)"
      },
      {
        kind: "concept",
        title: "Endorsement",
        body: "Endorsement is signing on the back to transfer the instrument. A Blank endorsement (signature only) makes it payable to bearer; a Full/Special endorsement names the next holder; a Restrictive endorsement ('Pay X only') stops further negotiation.",
        highlight: "Blank = to bearer · Full = names holder · Restrictive = stops negotiation"
      },
      {
        kind: "quiz",
        question: "A cheque is best described as which type of negotiable instrument?",
        opts: ["A promissory note payable on demand", "A bill of exchange drawn on a specified banker and payable on demand", "An unconditional promise by the maker", "A government security"],
        correct: 1,
        why: "Section 6 of the NI Act defines a cheque as a bill of exchange drawn on a specified banker and payable on demand."
      },
      {
        kind: "quiz",
        question: "What does an 'Account Payee' crossing on a cheque ensure?",
        opts: ["The cheque can be encashed over the counter", "Proceeds are credited only to the named payee's account", "The cheque becomes payable to bearer", "The cheque is valid for 6 months"],
        correct: 1,
        why: "An 'Account Payee' crossing directs the collecting banker to credit the proceeds only to the account of the named payee, reducing the risk of fraud."
      }
    ]
  },
  {
    id: "les_ppb_ethics",
    topicId: "ethics",
    subjectId: "PPB",
    title: "Ethics in Banking",
    badge: "Ethics",
    time: "5 min",
    emoji: "🧭",
    steps: [
      {
        kind: "concept",
        title: "Why Ethics Matter in Banking",
        body: "Banking runs on trust and handles other people's money, so ethical conduct — integrity, confidentiality, fairness and transparency — is fundamental. Ethics goes beyond legal compliance: an action can be legal yet unethical (e.g. mis-selling a product a customer doesn't need).",
        highlight: "Ethics > mere legal compliance"
      },
      {
        kind: "pillars",
        title: "Core values",
        pillars: [
          { n: "Integrity", d: "Honesty and consistency between word and action" },
          { n: "Confidentiality", d: "Protecting customer information" },
          { n: "Fairness", d: "Treating customers and colleagues without bias" },
          { n: "Accountability", d: "Owning decisions and their consequences" }
        ]
      },
      {
        kind: "concept",
        title: "Conflicts & Whistleblowing",
        body: "A conflict of interest arises when personal gain could influence professional duty (e.g. favouring a related party for a loan). Banks maintain whistle-blower mechanisms and codes of conduct so staff can report unethical practices without retaliation.",
        highlight: "Disclose conflicts · use whistle-blower channels"
      },
      {
        kind: "quiz",
        question: "Selling a customer an investment product that earns the banker a high commission but does not suit the customer's needs is an example of:",
        opts: ["Legal and ethical banking", "Mis-selling — a breach of ethics", "Priority sector lending", "A permitted conflict of interest"],
        correct: 1,
        why: "Recommending an unsuitable product for personal/institutional gain is mis-selling — it may not always be illegal, but it breaches the ethical duties of fairness and acting in the customer's interest."
      }
    ]
  },
  {
    id: "les_ieifs_inflation",
    topicId: "inflation",
    subjectId: "IEIFS",
    title: "Inflation: Types & Measures",
    badge: "Economy",
    time: "6 min",
    emoji: "🔥",
    steps: [
      {
        kind: "concept",
        title: "What is Inflation?",
        body: "Inflation is a sustained rise in the general price level, which erodes the purchasing power of money. Moderate inflation is normal; very high inflation (and its opposite, deflation) both harm the economy.",
        highlight: "Inflation = falling purchasing power of money"
      },
      {
        kind: "pillars",
        title: "Causes",
        pillars: [
          { n: "Demand-pull", d: "Too much money chasing too few goods (excess demand)" },
          { n: "Cost-push", d: "Rising input costs — wages, fuel, raw materials — push prices up" },
          { n: "Built-in", d: "Wage-price spiral as expectations of future inflation feed current prices" }
        ]
      },
      {
        kind: "concept",
        title: "WPI vs CPI",
        body: "The Wholesale Price Index (WPI) measures price changes at the wholesale/producer level and excludes services. The Consumer Price Index (CPI) measures retail prices including services and is the RBI's policy anchor. WPI is compiled by the Office of the Economic Adviser; CPI by the NSO.",
        highlight: "WPI: wholesale, no services | CPI: retail, RBI anchor"
      },
      {
        kind: "quiz",
        question: "Which index does the RBI use as its primary anchor for monetary policy?",
        opts: ["Wholesale Price Index (WPI)", "Consumer Price Index (CPI)", "Producer Price Index (PPI)", "GDP Deflator"],
        correct: 1,
        why: "Since adopting flexible inflation targeting, the RBI uses CPI (Combined) inflation as its primary anchor, with a target of 4% +/- 2%."
      },
      {
        kind: "quiz",
        question: "Inflation caused by a rise in the cost of raw materials, fuel and wages is called:",
        opts: ["Demand-pull inflation", "Cost-push inflation", "Deflation", "Disinflation"],
        correct: 1,
        why: "When higher input costs push up the price of finished goods, the resulting inflation is termed cost-push inflation."
      }
    ]
  },
  {
    id: "les_ieifs_fiscal_policy",
    topicId: "fiscal_policy",
    subjectId: "IEIFS",
    title: "Fiscal Policy & the Budget",
    badge: "Economy",
    time: "6 min",
    emoji: "🏦",
    steps: [
      {
        kind: "concept",
        title: "Fiscal vs Monetary Policy",
        body: "Fiscal policy is the Government's use of taxation and public spending to influence the economy. Monetary policy is the RBI's management of money supply and interest rates. The Union Budget is the main instrument of fiscal policy.",
        highlight: "Fiscal = Govt spending & taxes | Monetary = RBI rates"
      },
      {
        kind: "pillars",
        title: "Key deficit measures",
        pillars: [
          { n: "Fiscal Deficit", d: "Total expenditure minus total receipts (excluding borrowings) — the Govt's borrowing need" },
          { n: "Revenue Deficit", d: "Revenue expenditure minus revenue receipts" },
          { n: "Primary Deficit", d: "Fiscal deficit minus interest payments" }
        ]
      },
      {
        kind: "concept",
        title: "FRBM Act",
        body: "The Fiscal Responsibility and Budget Management (FRBM) Act, 2003 commits the Government to fiscal discipline, targeting a lower fiscal deficit as a percentage of GDP and limiting public debt over time.",
        highlight: "FRBM Act, 2003 = fiscal discipline targets"
      },
      {
        kind: "quiz",
        question: "The fiscal deficit of a government essentially indicates:",
        opts: ["Its total interest payments", "Its total borrowing requirement for the year", "Its revenue from taxes", "Its trade balance"],
        correct: 1,
        why: "Fiscal deficit = total expenditure - total receipts (excluding borrowings). It represents how much the government must borrow to meet its expenditure."
      },
      {
        kind: "quiz",
        question: "Primary deficit is calculated as:",
        opts: ["Fiscal deficit + interest payments", "Fiscal deficit - interest payments", "Revenue deficit + capital expenditure", "Total receipts - total expenditure"],
        correct: 1,
        why: "Primary deficit = Fiscal deficit - Interest payments. It shows the borrowing requirement excluding the burden of past debt servicing."
      }
    ]
  },
  {
    id: "les_ieifs_financial_system",
    topicId: "financial_system",
    subjectId: "IEIFS",
    title: "Structure of the Financial System",
    badge: "Financial Markets",
    time: "5 min",
    emoji: "🏗️",
    steps: [
      {
        kind: "concept",
        title: "Four Components",
        body: "A financial system channels savings to investment through four interlinked components: financial institutions, financial markets, financial instruments, and financial services.",
        highlight: "Institutions · Markets · Instruments · Services"
      },
      {
        kind: "pillars",
        title: "Institutions & markets",
        pillars: [
          { n: "Institutions", d: "Banks, NBFCs, insurance companies, mutual funds, pension funds" },
          { n: "Money Market", d: "Short-term funds (< 1 year): call money, T-bills, CP, CD" },
          { n: "Capital Market", d: "Long-term funds (> 1 year): equity and debt securities" },
          { n: "Forex Market", d: "Trading of foreign currencies" }
        ]
      },
      {
        kind: "concept",
        title: "Organised vs Unorganised",
        body: "The organised sector (RBI-regulated banks, NBFCs, exchanges) operates under formal regulation. The unorganised sector (moneylenders, indigenous bankers, chit funds) is largely outside the regulatory net. Financial inclusion aims to bring more people into the organised system.",
        highlight: "Organised (regulated) vs Unorganised (informal)"
      },
      {
        kind: "quiz",
        question: "Which of the following is NOT one of the four components of a financial system?",
        opts: ["Financial institutions", "Financial markets", "Financial instruments", "Fiscal deficit"],
        correct: 3,
        why: "The four components are institutions, markets, instruments and services. Fiscal deficit is a government finance concept, not a component of the financial system."
      }
    ]
  },
  {
    id: "les_ieifs_capital_market",
    topicId: "capital_market",
    subjectId: "IEIFS",
    title: "Capital Market Basics",
    badge: "Financial Markets",
    time: "6 min",
    emoji: "📑",
    steps: [
      {
        kind: "concept",
        title: "Primary vs Secondary Market",
        body: "The primary market is where securities are issued for the first time (e.g. an IPO), raising fresh capital for the issuer. The secondary market (stock exchanges like NSE/BSE) is where existing securities are traded among investors, providing liquidity.",
        highlight: "Primary = new issue (IPO) | Secondary = trading"
      },
      {
        kind: "pillars",
        title: "Instruments",
        pillars: [
          { n: "Equity Shares", d: "Ownership stake; dividends and voting rights" },
          { n: "Preference Shares", d: "Fixed dividend, priority over equity in repayment" },
          { n: "Debentures / Bonds", d: "Debt instruments paying fixed interest" }
        ]
      },
      {
        kind: "concept",
        title: "Market Infrastructure",
        body: "SEBI regulates the capital market. Securities are held in electronic (demat) form with depositories — NSDL and CDSL. Trades settle on a T+1 rolling basis in India.",
        highlight: "Regulator: SEBI · Depositories: NSDL, CDSL · Settlement: T+1"
      },
      {
        kind: "quiz",
        question: "An Initial Public Offering (IPO) is a transaction in the:",
        opts: ["Secondary market", "Primary market", "Money market", "Forex market"],
        correct: 1,
        why: "An IPO is the first sale of shares to the public, raising fresh capital — it takes place in the primary market. Subsequent trading happens in the secondary market."
      },
      {
        kind: "quiz",
        question: "Which entities act as depositories for holding securities in dematerialised form in India?",
        opts: ["NSE and BSE", "NSDL and CDSL", "RBI and SEBI", "NABARD and SIDBI"],
        correct: 1,
        why: "NSDL and CDSL are the two depositories that hold securities in electronic (demat) form; NSE and BSE are stock exchanges where trading happens."
      }
    ]
  },
  {
    id: "les_ieifs_nbfc",
    topicId: "nbfc",
    subjectId: "IEIFS",
    title: "NBFCs vs Banks",
    badge: "Institutions",
    time: "5 min",
    emoji: "🏢",
    steps: [
      {
        kind: "concept",
        title: "What is an NBFC?",
        body: "A Non-Banking Financial Company is registered under the Companies Act and lends or invests, but unlike a bank it cannot accept demand deposits, is not part of the payment & settlement system, and depositors are not covered by DICGC deposit insurance.",
        highlight: "NBFC: no demand deposits, no cheques, no DICGC cover"
      },
      {
        kind: "pillars",
        title: "Bank vs NBFC",
        pillars: [
          { n: "Demand deposits", d: "Banks can accept; NBFCs cannot" },
          { n: "Payment system", d: "Banks issue cheques/are in the clearing system; NBFCs are not" },
          { n: "Reserve ratios", d: "CRR/SLR apply to banks, not to NBFCs" },
          { n: "Deposit insurance", d: "DICGC covers bank deposits, not NBFC deposits" }
        ]
      },
      {
        kind: "quiz",
        question: "Which of the following can a bank do that an NBFC generally cannot?",
        opts: ["Provide loans", "Accept demand deposits and issue cheques", "Invest in securities", "Lend for vehicle purchase"],
        correct: 1,
        why: "NBFCs can lend and invest but cannot accept demand deposits or issue cheques, and are not part of the payment and settlement system — features unique to banks."
      }
    ]
  },
  {
    id: "les_rbwm_intro",
    topicId: "retail_banking_intro",
    subjectId: "RBWM",
    title: "Introduction to Retail Banking",
    badge: "Retail",
    time: "5 min",
    emoji: "🏪",
    steps: [
      {
        kind: "concept",
        title: "What is Retail Banking?",
        body: "Retail banking provides banking services to individual consumers rather than companies — deposits, loans, cards, and wealth products delivered in high volume but at low individual value. It is characterised by a large, diversified customer base and standardised products.",
        highlight: "Retail = mass-market, individual customers, low ticket size"
      },
      {
        kind: "pillars",
        title: "Why banks love retail",
        pillars: [
          { n: "Diversified risk", d: "Many small loans spread default risk vs a few large corporate loans" },
          { n: "Stable deposits", d: "Retail CASA deposits are sticky and low-cost" },
          { n: "Cross-sell", d: "A broad base to sell cards, insurance and investments" }
        ]
      },
      {
        kind: "concept",
        title: "Delivery Channels",
        body: "Retail banking is delivered through branches, ATMs, internet and mobile banking, business correspondents (BCs), and points of sale. The shift to digital channels has sharply lowered the cost per transaction.",
        highlight: "Branch · ATM · Net/Mobile · BC · POS"
      },
      {
        kind: "quiz",
        question: "Which of the following best characterises retail banking?",
        opts: ["A few high-value corporate loans", "High-volume, low-value services to individual customers", "Only government securities trading", "Wholesale inter-bank lending"],
        correct: 1,
        why: "Retail banking serves a large number of individual customers with standardised, relatively low-value products — the opposite of high-value wholesale/corporate banking."
      }
    ]
  },
  {
    id: "les_rbwm_home_loan",
    topicId: "retail_loan_products",
    subjectId: "RBWM",
    title: "Home Loans: LTV & EMI",
    badge: "Credit",
    time: "6 min",
    emoji: "🏠",
    steps: [
      {
        kind: "concept",
        title: "Loan-to-Value (LTV)",
        body: "LTV is the ratio of the loan amount to the property value; the rest is the borrower's margin/down-payment. The RBI caps LTV by loan size — up to 90% for home loans up to ₹30 lakh, 80% for ₹30-75 lakh, and 75% above ₹75 lakh.",
        highlight: "LTV cap: 90% (≤₹30L) · 80% (₹30-75L) · 75% (>₹75L)"
      },
      {
        kind: "scenario",
        title: "Computing the down-payment",
        problem: "A borrower buys a flat valued at ₹40 lakh. The bank's maximum LTV for this slab is 80%.",
        steps: [
          "Maximum loan = 80% of ₹40 lakh = ₹32 lakh",
          "Borrower's margin (down-payment) = ₹40 lakh - ₹32 lakh = ₹8 lakh"
        ],
        verdict: "The bank can fund up to ₹32 lakh; the borrower must arrange ₹8 lakh as margin."
      },
      {
        kind: "concept",
        title: "EMI Basics",
        body: "An Equated Monthly Instalment (EMI) repays principal plus interest in equal monthly amounts. Early EMIs are interest-heavy and later ones principal-heavy. A longer tenure lowers the EMI but raises total interest paid.",
        highlight: "Longer tenure -> lower EMI but more total interest"
      },
      {
        kind: "quiz",
        question: "For a home loan of ₹50 lakh against a property valued at ₹60 lakh, what is the Loan-to-Value (LTV) ratio?",
        opts: ["60%", "70%", "83.3%", "120%"],
        correct: 2,
        why: "LTV = Loan / Property Value = 50 / 60 = 83.3%."
      }
    ]
  },
  {
    id: "les_rbwm_wealth",
    topicId: "wealth_management",
    subjectId: "RBWM",
    title: "Wealth Management Basics",
    badge: "Wealth",
    time: "5 min",
    emoji: "💎",
    steps: [
      {
        kind: "concept",
        title: "What Wealth Management Does",
        body: "Wealth management is an advisory service that helps clients grow and protect wealth through financial planning, investment advice, tax planning, retirement and estate planning — matched to the client's goals and risk profile.",
        highlight: "Advice across investing, tax, retirement & estate"
      },
      {
        kind: "pillars",
        title: "Asset allocation & risk",
        pillars: [
          { n: "Risk profile", d: "Conservative, moderate or aggressive — drives the asset mix" },
          { n: "Diversification", d: "Spreading across asset classes to reduce risk" },
          { n: "Rebalancing", d: "Periodically restoring the target asset allocation" }
        ]
      },
      {
        kind: "concept",
        title: "Risk vs Return",
        body: "Higher expected returns come with higher risk. Equity offers higher long-term returns with more volatility; debt is steadier with lower returns. A suitable portfolio balances the two according to the client's goals and time horizon.",
        highlight: "Higher return -> higher risk; match to horizon"
      },
      {
        kind: "quiz",
        question: "Spreading investments across different asset classes to reduce overall risk is called:",
        opts: ["Leverage", "Diversification", "Speculation", "Arbitrage"],
        correct: 1,
        why: "Diversification reduces unsystematic risk by ensuring poor performance in one asset is offset by others, a core principle of wealth management."
      }
    ]
  },
  {
    id: "les_rbwm_mutual_funds",
    topicId: "mutual_funds",
    subjectId: "RBWM",
    title: "Mutual Funds & SIPs",
    badge: "Wealth",
    time: "6 min",
    emoji: "📈",
    steps: [
      {
        kind: "concept",
        title: "What is a Mutual Fund?",
        body: "A mutual fund pools money from many investors and invests it in a diversified portfolio managed by a professional fund manager, regulated by SEBI. Investors hold units; gains/losses are shared in proportion to holdings.",
        highlight: "Pooled, professionally managed, SEBI-regulated"
      },
      {
        kind: "pillars",
        title: "By asset class",
        pillars: [
          { n: "Equity funds", d: "Invest mainly in shares — higher risk and return" },
          { n: "Debt funds", d: "Invest in bonds/money-market — lower risk" },
          { n: "Hybrid funds", d: "Mix of equity and debt" }
        ]
      },
      {
        kind: "concept",
        title: "NAV & SIP",
        body: "Net Asset Value (NAV) is the per-unit market value of the fund, computed daily. A Systematic Investment Plan (SIP) invests a fixed amount at regular intervals, giving rupee-cost averaging and the benefit of compounding over time.",
        highlight: "NAV = per-unit value | SIP = invest fixed sum regularly"
      },
      {
        kind: "quiz",
        question: "The per-unit market value of a mutual fund, calculated daily, is known as the:",
        opts: ["Expense Ratio", "Net Asset Value (NAV)", "Coupon Rate", "Face Value"],
        correct: 1,
        why: "NAV (Net Asset Value) is the fund's total net assets divided by the number of outstanding units, and it is the price at which units are bought or sold."
      },
      {
        kind: "quiz",
        question: "A Systematic Investment Plan (SIP) primarily helps an investor by providing:",
        opts: ["Guaranteed returns", "Rupee-cost averaging and disciplined investing", "Exemption from all taxes", "Insurance cover"],
        correct: 1,
        why: "By investing a fixed amount regularly, a SIP buys more units when prices are low and fewer when high (rupee-cost averaging) and instils investing discipline; it does not guarantee returns."
      }
    ]
  }
];
