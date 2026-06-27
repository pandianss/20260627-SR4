export const QUESTION_BANK = [
  {
    id: "q_ieifs_repo",
    subjectId: "IEIFS",
    topicId: "monetary_policy",
    difficulty: "Medium",
    q: "When the Reserve Bank of India (RBI) raises the Repo Rate, what is the expected impact on the banking system?",
    opts: [
      "Lending to commercial banks becomes cheaper",
      "Lending rates for retail consumers decrease",
      "Cost of borrowing for commercial banks increases, leading to higher consumer lending rates",
      "Money supply in the economy increases rapidly"
    ],
    correct: 2,
    why: "Repo rate is the rate at which the RBI lends money to commercial banks. Raising it increases the cost of funds for banks, which they pass on to consumers by raising interest rates, thus tightening liquidity and helping curb inflation."
  },
  {
    id: "q_ieifs_inflation",
    subjectId: "IEIFS",
    topicId: "inflation",
    difficulty: "Medium",
    q: "Which index is primarily used by the RBI as the nominal anchor for measuring retail inflation under the inflation targeting framework?",
    opts: [
      "Wholesale Price Index (WPI)",
      "Consumer Price Index (CPI) Combined",
      "GDP Deflator",
      "Index of Industrial Production (IIP)"
    ],
    correct: 1,
    why: "The RBI adopted Consumer Price Index (CPI) Combined as the key metric for inflation targeting to reflect real cost of living fluctuations experienced by household retail consumers."
  },
  {
    id: "q_rbwm_products",
    subjectId: "RBWM",
    topicId: "banking_products",
    difficulty: "Easy",
    q: "Which of the following is classified as a retail bank asset product?",
    opts: [
      "Savings Bank Account",
      "Fixed Deposit Scheme",
      "Home Loan Account",
      "Current Account"
    ],
    correct: 2,
    why: "Asset products are products where the bank lends money to customer borrowers, generating interest income. Savings, Fixed, and Current accounts represent liabilities since the bank holds these deposits for customers."
  },
  {
    id: "q_rbwm_score",
    subjectId: "RBWM",
    topicId: "credit_scoring",
    difficulty: "Medium",
    q: "What is the standard numeric range for a CIBIL credit score utilized in retail credit evaluation in India?",
    opts: [
      "100 to 1000",
      "300 to 900",
      "0 to 100",
      "500 to 1500"
    ],
    correct: 1,
    why: "CIBIL scores range from 300 to 900. Higher numbers represent lower default risk, facilitating quick retail loan approvals."
  },
  {
    id: "q_afm_pv",
    subjectId: "AFM",
    topicId: "time_value_of_money",
    difficulty: "Medium",
    q: "Calculate the Present Value of ₹121 received 2 years from now, discounted at an annual interest rate of 10% (in ₹).",
    opts: [
      "₹90",
      "₹100",
      "₹110",
      "₹120"
    ],
    correct: 1,
    why: "Using PV formula: PV = FV / (1 + r)^n. PV = 121 / (1 + 0.10)^2 = 121 / 1.21 = ₹100."
  },
  {
    id: "q_afm_depr",
    subjectId: "AFM",
    topicId: "depreciation",
    difficulty: "Medium",
    q: "An asset cost ₹10,000 with a scrap value of ₹1,000 and a useful life of 5 years. Under the Straight Line Method (SLM), what is the annual depreciation charge (in ₹)?",
    opts: [
      "₹1,500",
      "₹1,800",
      "₹2,000",
      "₹2,200"
    ],
    correct: 1,
    why: "SLM Depreciation = (Cost - Scrap Value) / Useful Life = (10,000 - 1,000) / 5 = ₹1,800 per annum."
  },
  {
    id: "q_ieifs_gdp",
    subjectId: "IEIFS",
    topicId: "gdp",
    difficulty: "Medium",
    q: "If a country's Nominal GDP is ₹120 Crore and the GDP Deflator is 120 (or 1.20), what is its Real GDP?",
    opts: [
      "₹100 Crore",
      "₹110 Crore",
      "₹120 Crore",
      "₹144 Crore"
    ],
    correct: 0,
    why: "Real GDP = Nominal GDP / GDP Deflator (expressed as decimal) = 120 / 1.20 = ₹100 Crore."
  },
  {
    id: "q_ieifs_regulators",
    subjectId: "IEIFS",
    topicId: "financial_regulators",
    difficulty: "Easy",
    q: "Which regulator supervises and regulates the functioning of Mutual Funds in India?",
    opts: [
      "Reserve Bank of India (RBI)",
      "Securities and Exchange Board of India (SEBI)",
      "Insurance Regulatory and Development Authority (IRDAI)",
      "Pension Fund Regulatory and Development Authority (PFRDA)"
    ],
    correct: 1,
    why: "SEBI regulates the securities markets, including asset management companies and mutual funds in India."
  },
  {
    id: "q_ppb_psl",
    subjectId: "PPB",
    topicId: "crr",
    difficulty: "Medium",
    q: "What is the overall Priority Sector Lending (PSL) target for domestic scheduled commercial banks in India?",
    opts: [
      "32% of ANBC",
      "40% of ANBC",
      "18% of ANBC",
      "7.5% of ANBC"
    ],
    correct: 1,
    why: "Domestic Scheduled Commercial Banks and Foreign Banks with 20 or more branches must allocate 40% of ANBC or Credit Equivalent Amount of Off-Balance Sheet Exposure, whichever is higher, to priority sectors."
  },
  {
    id: "q_ppb_payment_systems",
    subjectId: "PPB",
    topicId: "core_banking",
    difficulty: "Medium",
    q: "What is the minimum transaction limit for retail fund transfers via Real Time Gross Settlement (RTGS)?",
    opts: [
      "No minimum limit",
      "₹50,000",
      "₹1 Lakh",
      "₹2 Lakh"
    ],
    correct: 3,
    why: "RTGS is meant for high-value settlement. The minimum amount for transferring funds via RTGS is ₹2 Lakh, with no maximum ceiling."
  },
  {
    id: "q_afm_capital_budgeting",
    subjectId: "AFM",
    topicId: "time_value_of_money",
    difficulty: "Medium",
    q: "If a project has an initial outflow of ₹1,000 and the present value of its future cash inflows is ₹1,200, what is its NPV?",
    opts: [
      "-₹200",
      "₹200",
      "₹1,000",
      "₹1,200"
    ],
    correct: 1,
    why: "NPV = Present Value of Inflows - Initial Outflow = 1,200 - 1,000 = ₹200."
  },
  {
    id: "q_afm_accounting_cycle",
    subjectId: "AFM",
    topicId: "balance_sheet",
    difficulty: "Medium",
    q: "If a business has Assets of ₹50,000 and Liabilities of ₹20,000, what is its Owner's Equity?",
    opts: [
      "₹20,000",
      "₹30,000",
      "₹50,000",
      "₹70,000"
    ],
    correct: 1,
    why: "Equity = Assets - Liabilities = 50,000 - 20,000 = ₹30,000."
  },
  {
    id: "q_rbwm_recovery",
    subjectId: "RBWM",
    topicId: "credit_scoring",
    difficulty: "Medium",
    q: "What is the maximum monetary limit for cases referred to Lok Adalats for debt recovery settlement?",
    opts: [
      "₹5 Lakh",
      "₹10 Lakh",
      "₹20 Lakh",
      "No limit"
    ],
    correct: 2,
    why: "Banks refer cases with outstanding balances up to ₹20 Lakh to Lok Adalats for recovery through compromise settlement."
  },
  {
    id: "q_rbwm_marketing",
    subjectId: "RBWM",
    topicId: "marketing",
    difficulty: "Medium",
    q: "Which of the following represents 'Physical Evidence' in the retail banking marketing mix?",
    opts: [
      "Interest rates on loans",
      "Friendly bank tellers",
      "A clean, modern bank branch lobby or intuitive mobile app",
      "Direct mail advertisements"
    ],
    correct: 2,
    why: "Physical Evidence is the environment in which the service is delivered and where the firm and customer interact, such as branch ambience or app interfaces."
  },
  {
    id: "q_ppb_banker_rights",
    subjectId: "PPB",
    topicId: "banker_customer_rights",
    difficulty: "Medium",
    q: "Under what legal concept can a bank combine a customer's credit balance in one account with a debit balance in another to recover overdue debt?",
    opts: [
      "Right of Appropriation",
      "Right of Lien",
      "Right of Set-off",
      "Right of Pledge"
    ],
    correct: 2,
    why: "The Right of Set-off is the statutory right of a banker to combine two accounts of the same debtor/creditor capacity to adjust a debt."
  },
  {
    id: "q_ppb_collaterals",
    subjectId: "PPB",
    topicId: "collateral_types",
    difficulty: "Medium",
    q: "When a bank extends a loan against gold ornaments and takes physical custody of the gold, what type of charge is created?",
    opts: [
      "Hypothecation",
      "Mortgage",
      "Pledge",
      "Lien"
    ],
    correct: 2,
    why: "A pledge involves bailment (transfer of possession) of movable goods to the creditor bank as security for a loan."
  },
  {
    id: "q_ieifs_money_market",
    subjectId: "IEIFS",
    topicId: "money_market",
    difficulty: "Medium",
    q: "What is the term used for inter-bank fund borrowing/lending for a period of exactly one day?",
    opts: [
      "Notice Money",
      "Term Money",
      "Call Money",
      "Commercial Paper"
    ],
    correct: 2,
    why: "Funds borrowed or lent in the inter-bank market for one day are termed Call Money. If for 2 to 14 days, it is called Notice Money."
  },
  {
    id: "q_afm_ratio_analysis",
    subjectId: "AFM",
    topicId: "ratio_analysis",
    difficulty: "Medium",
    q: "Calculate the Current Ratio of a firm with Current Assets of ₹1,00,000, Current Liabilities of ₹50,000, and Inventory of ₹20,000.",
    opts: [
      "1.6:1",
      "2.0:1",
      "2.5:1",
      "3.0:1"
    ],
    correct: 1,
    why: "Current Ratio = Current Assets / Current Liabilities = 1,00,000 / 50,000 = 2.0:1."
  },
  {
    id: "q_rbwm_npa",
    subjectId: "RBWM",
    topicId: "npa_classification",
    difficulty: "Medium",
    q: "After what period of remaining in the Non-Performing Asset (NPA) category is an asset classified as a 'Doubtful Asset'?",
    opts: [
      "6 months",
      "12 months",
      "18 months",
      "24 months"
    ],
    correct: 1,
    why: "An asset is classified as substandard if it remains an NPA for up to 12 months, after which it transitions to the doubtful category."
  },
  {
    id: "q_ppb_ni_parties",
    subjectId: "PPB",
    topicId: "negotiable_instruments",
    difficulty: "Medium",
    q: "A bill of exchange involves how many parties in its basic form?",
    opts: ["Two — maker and payee", "Three — drawer, drawee and payee", "Four — drawer, drawee, payee and endorser", "One — the bearer"],
    correct: 1,
    why: "A bill of exchange is an order to pay involving three parties: the drawer (who makes the order), the drawee (who is ordered to pay), and the payee (who receives payment)."
  },
  {
    id: "q_ppb_crossing",
    subjectId: "PPB",
    topicId: "negotiable_instruments",
    difficulty: "Easy",
    q: "Two transverse parallel lines on the face of a cheque, without any words, constitute a:",
    opts: ["Special crossing", "General crossing", "Account payee crossing", "Not-negotiable crossing"],
    correct: 1,
    why: "Two parallel transverse lines (with or without the words '& Co.') form a general crossing, meaning the cheque must be paid through a bank account and not across the counter."
  },
  {
    id: "q_ppb_imps_operator",
    subjectId: "PPB",
    topicId: "payment_systems",
    difficulty: "Medium",
    q: "NEFT and RTGS are operated by which entity?",
    opts: ["NPCI", "The Reserve Bank of India", "Indian Banks' Association", "SEBI"],
    correct: 1,
    why: "NEFT and RTGS are operated directly by the RBI. IMPS, UPI and RuPay are operated by the National Payments Corporation of India (NPCI)."
  },
  {
    id: "q_ppb_joint_account",
    subjectId: "PPB",
    topicId: "types_of_accounts",
    difficulty: "Medium",
    q: "In a 'Former or Survivor' joint account, who may operate the account while both holders are alive?",
    opts: ["Either holder", "Only the first (former) holder", "Both holders jointly", "Only the second holder"],
    correct: 1,
    why: "Under 'Former or Survivor', only the first-named (former) holder can operate the account during the lifetime of both; the survivor gets rights only after the former's death."
  },
  {
    id: "q_ppb_relationship_locker",
    subjectId: "PPB",
    topicId: "banker_customer_relationship",
    difficulty: "Medium",
    q: "When a customer hires a safe-deposit locker, the bank-customer relationship is best described as:",
    opts: ["Debtor and creditor", "Lessor and lessee", "Trustee and beneficiary", "Principal and agent"],
    correct: 1,
    why: "Hiring a safe-deposit locker creates a lessor (bank) and lessee (customer) relationship — the bank rents out space rather than taking custody of the contents."
  },
  {
    id: "q_ppb_ethics_missell",
    subjectId: "PPB",
    topicId: "ethics",
    difficulty: "Easy",
    q: "Recommending an unsuitable high-commission product to a customer primarily for the banker's gain is known as:",
    opts: ["Cross-selling", "Mis-selling", "Up-selling", "Priority lending"],
    correct: 1,
    why: "Mis-selling is recommending a product that does not meet the customer's needs, usually driven by incentives — an ethical breach of the duty to act in the customer's interest."
  },
  {
    id: "q_ieifs_mpc",
    subjectId: "IEIFS",
    topicId: "monetary_policy",
    difficulty: "Medium",
    q: "The Monetary Policy Committee (MPC), which sets the policy repo rate, comprises how many members?",
    opts: ["Three", "Five", "Six", "Nine"],
    correct: 2,
    why: "The MPC has six members — three from the RBI including the Governor (who has a casting vote) and three nominated by the Central Government."
  },
  {
    id: "q_ieifs_cpi_target",
    subjectId: "IEIFS",
    topicId: "inflation",
    difficulty: "Medium",
    q: "Under flexible inflation targeting, what is the CPI inflation target (with tolerance band) for the RBI?",
    opts: ["2% +/- 2%", "4% +/- 2%", "5% +/- 1%", "6% +/- 2%"],
    correct: 1,
    why: "The Government, in consultation with the RBI, has set the CPI inflation target at 4% with a tolerance band of +/- 2% (i.e. between 2% and 6%)."
  },
  {
    id: "q_ieifs_fiscal_deficit",
    subjectId: "IEIFS",
    topicId: "fiscal_policy",
    difficulty: "Medium",
    q: "Fiscal deficit is defined as:",
    opts: ["Revenue expenditure minus revenue receipts", "Total expenditure minus total receipts excluding borrowings", "Total receipts minus interest payments", "Capital expenditure minus capital receipts"],
    correct: 1,
    why: "Fiscal deficit = total expenditure - total receipts (excluding borrowings); it equals the government's net borrowing requirement for the year."
  },
  {
    id: "q_ieifs_dicgc",
    subjectId: "IEIFS",
    topicId: "financial_regulators",
    difficulty: "Easy",
    q: "Bank deposit insurance provided by the DICGC covers each depositor up to:",
    opts: ["₹1 lakh", "₹2 lakh", "₹5 lakh", "₹10 lakh"],
    correct: 2,
    why: "The DICGC, a subsidiary of the RBI, insures bank deposits up to ₹5 lakh per depositor per bank (principal plus interest)."
  },
  {
    id: "q_ieifs_ipo_market",
    subjectId: "IEIFS",
    topicId: "capital_market",
    difficulty: "Easy",
    q: "Shares offered to the public for the first time through an IPO are issued in the:",
    opts: ["Secondary market", "Primary market", "Money market", "Commodity market"],
    correct: 1,
    why: "An IPO raises fresh capital by issuing securities for the first time, which happens in the primary market; later trading of those shares occurs in the secondary market."
  },
  {
    id: "q_ieifs_nbfc_deposit",
    subjectId: "IEIFS",
    topicId: "nbfc",
    difficulty: "Medium",
    q: "Which activity is a bank permitted to do but an NBFC is generally NOT?",
    opts: ["Grant loans", "Accept demand deposits and issue cheques", "Invest in shares", "Offer fixed-term financing"],
    correct: 1,
    why: "NBFCs cannot accept demand deposits or issue cheques and are not part of the payment and settlement system — these are exclusive to banks."
  },
  {
    id: "q_rbwm_ltv",
    subjectId: "RBWM",
    topicId: "retail_loan_products",
    difficulty: "Medium",
    q: "For a home loan of ₹24 lakh on a property worth ₹30 lakh, what is the Loan-to-Value (LTV) ratio?",
    opts: ["70%", "80%", "90%", "125%"],
    correct: 1,
    why: "LTV = Loan / Property Value = 24 / 30 = 80%."
  },
  {
    id: "q_rbwm_sma2",
    subjectId: "RBWM",
    topicId: "npa_classification",
    difficulty: "Medium",
    q: "An account with principal or interest overdue for 61 to 90 days is classified as:",
    opts: ["SMA-0", "SMA-1", "SMA-2", "Doubtful Asset"],
    correct: 2,
    why: "SMA-2 covers overdues of 61-90 days; beyond 90 days the account becomes an NPA."
  },
  {
    id: "q_rbwm_nav",
    subjectId: "RBWM",
    topicId: "mutual_funds",
    difficulty: "Easy",
    q: "The price at which units of a mutual fund scheme are bought or redeemed is its:",
    opts: ["Face value", "Net Asset Value (NAV)", "Coupon rate", "Book value"],
    correct: 1,
    why: "The NAV is the per-unit value of the fund's net assets, calculated daily, and is the basis for purchase and redemption."
  },
  {
    id: "q_rbwm_diversification",
    subjectId: "RBWM",
    topicId: "wealth_management",
    difficulty: "Easy",
    q: "Holding a mix of equity, debt and gold to reduce portfolio risk is an application of:",
    opts: ["Leverage", "Diversification", "Hedging via derivatives", "Speculation"],
    correct: 1,
    why: "Diversification spreads investments across asset classes so weak performance in one is offset by others, lowering overall portfolio risk."
  },
  {
    id: "q_rbwm_crosssell",
    subjectId: "RBWM",
    topicId: "marketing",
    difficulty: "Easy",
    q: "Offering a credit card to an existing savings-account holder is an example of:",
    opts: ["Up-selling", "Cross-selling", "De-marketing", "Re-marketing"],
    correct: 1,
    why: "Cross-selling offers a different, complementary product (credit card) to an existing customer (savings-account holder)."
  }
];
export const QUESTION_BANK_SUPPLEMENT = [];
