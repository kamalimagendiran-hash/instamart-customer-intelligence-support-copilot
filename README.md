# Instamart Customer Intelligence & Support Copilot

An end-to-end offline customer intelligence and AI-assisted support system built for the Instamart capstone project.

The project combines **data cleaning, SQL analytics, customer segmentation, lapse prediction, support-ticket triage, privacy-safe processing, policy-based RAG, and tool-using refund workflows** into one reproducible pipeline.

---

## Overview

This capstone demonstrates how raw customer, order, product, and support-ticket data can be transformed into actionable business insights and AI-assisted customer support workflows.

The project is divided into four major parts:

- **Part A — Data Cleaning, SQL Analytics & EDA**
- **Part B — Customer Segmentation & Lapse Prediction**
- **Part C — Support Ticket Triage & Guardrails**
- **Part D — Policy RAG & Refund Agent**

### Project Highlights

- **1,200 customers**
- **13,084 raw orders**
- **12,309 distinct order IDs after cleaning**
- **11,110 completed orders**
- **₹29.99L completed-order revenue**
- **1,175 customers in the RFM dataset**
- **4 customer segments**
- **443 lapsed customers**
- **164 support tickets**
- **156 eligible tickets**
- **85.7% zero-shot classification accuracy**
- **100% few-shot classification accuracy**
- **5 policy documents**
- **15 policy chunks**
- **7 ReAct scenarios**
- **Crash/resume checkpoint demonstration**
- **Privacy-safe PII redaction**
- **Offline and reproducible workflow**

---

# Reproduce

## Requirements

Recommended environment:

- Python 3.13.17
- VS Code
- Jupyter Notebook
- Pandas
- NumPy
- Scikit-learn
- SQLite
- Joblib

Install dependencies:

```bash
pip install -r requirements.txt
```

## Project Structure

```text
captone/
│
├── data/
│   ├── instamart.db
│   ├── clean/
│   ├── raw/
│   └── policies/
│
├── notebook/
│   ├── 01_data_audit
│   ├── 02_customer_segmentation_lapse_prediction
│   ├── 03_support_ticket_triage
│   └── 04_policy_rag_refund_agent
│
├── outputs/
│   ├── customer_segments.csv
│   ├── lapse_model.joblib
│   ├── retention_list.csv
│   ├── triage_results.csv
│   ├── triage_budget_demo.csv
│   ├── agent_runs.jsonl
│   └── refund_ledger.jsonl
│
├── sql/
│
├── src/
│
├── state/
│
├── generate_data.py
├── mock_llm.py
├── requirements.txt
└── README.md
```

### Setup Commands

Create the virtual environment:

```bash
python -m venv .venv
```

Activate on Windows PowerShell:

```powershell
.venv\Scripts\activate
```

Install dependencies:

```bash
python -m pip install --upgrade pip
pip install -r requirements.txt
```

Generate the reproducible dataset:

```bash
python generate_data.py
```

Run the notebooks in order:

```text
01_data_audit
02_customer_segmentation_lapse_prediction
03_support_ticket_triage
04_policy_rag_refund_agent
```

The generated SQLite database is:

```text
data/instamart.db
```

The main project outputs are stored under:

```text
outputs/
```

---

# Part A — Data Cleaning, SQL Analytics & EDA

## A1. Customer Data Audit

The customer dataset contains:

- **1,200 customers**
- **61 blank age values**
- Invalid age values: **-4, 150, 200, 280, 999**
- Therefore **6 invalid age values**
- Median valid age used for age imputation: **40**
- **30 blank gender values**
- **24 inconsistent raw city spellings**
- Cities were normalized into **6 standard city values**

### Cleaning Rules

Age values outside the reasonable range were treated as invalid and converted to missing before imputation.

Missing age values were imputed using the median age of the customer's city.

Gender values were normalized to consistent categories, with blank values handled as unknown where required.

City names were standardized from inconsistent raw spellings into **6 normalized cities**.

Signup dates were converted into a consistent datetime format.

---

## A2. Product Data Audit

The product dataset contains:

- **40 products**
- Product identifiers were validated.
- Product prices and categories were checked for consistency.
- Clean product data was used for downstream order and revenue analysis.

---

## A3. Order Data Audit

The raw order dataset contains:

- **13,084 raw order rows**
- **119 exact duplicate rows**
- **656 pending orders**
- **12,309 distinct order IDs after cleaning**

Additional data-quality issues identified:

- **53 missing order amounts**
- **65 non-numeric `"error"` order amounts**
- **120 non-numeric amount values in the raw amount-quality check**
- **106 negative delivery-time values**
- **2,541 blank delivery-time values**
- Missing delivery percentage: **19.42%**

Exact duplicate rows were removed before the repeated-order-ID cleanup.

The latest valid record per repeated `order_id` was retained, resulting in:

**12,309 distinct orders.**

---

## A4. Order Amount Validation

Product prices were compared against order amounts to validate transaction values.

The validated amount comparison identified:

**12,847 order amounts matching the expected product-price relationship.**

Invalid and non-numeric order amounts were handled before downstream aggregation.

---

## A5. Outlier Analysis

The completed-order amount distribution was evaluated using the IQR method.

Key values:

- **Q1 = 64.8**
- **Q3 = 297.0**
- **IQR = 232.2**
- **Lower Fence = -283.5**
- **Upper Fence = 645.3**
- **897 outliers**
- Outlier rate = **8.07%**

The outlier analysis was used for EDA and interpretation rather than automatically deleting legitimate high-value transactions.

---

## A6. Completed and Cancelled Orders

After cleaning:

- **11,110 completed orders**
- **1,199 cancelled orders**
- Completed-order revenue = **₹2,998,668.80**
- Revenue in compact form = **₹29.99L**

The completed-order revenue is calculated using valid completed transactions.

---

## A7. Revenue by City

Completed-order revenue was analyzed across the normalized cities.

- **Bengaluru — ₹523,643.40**
- **Chennai — ₹463,629.15**
- **Delhi — ₹502,829.80**
- **Hyderabad — ₹528,589.90**
- **Mumbai — ₹479,058.50**
- **Pune — ₹500,918.05**

Hyderabad generated the highest revenue among the six normalized cities.

---

## A8. Revenue by Product Category

Completed-order revenue by category:

- **Dairy — ₹531,938.95**
- **Electronics — ₹1,219,248.10**
- **Grocery — ₹614,293.30**
- **Personal Care — ₹168,433.95**
- **Snacks — ₹464,754.50**

Electronics produced the highest category revenue.

---

## A9. Customer-Level SQL Analysis

SQL analysis was performed using the cleaned analytical SQLite database.

Key findings include:

- **25 customers had no completed orders**
- **30 high-value customers** were identified using the project threshold
- Top customer: **C0693**
- Top customer completed-order spend: **₹13,776.55**

Additional SQL analysis was used for:

- Customer spending
- Order behaviour
- City-level performance
- Product/category analysis
- Customer-level business insights
- Revenue trends

---

## A10. Correlation Analysis

The correlation between order amount and discount was:

**-0.095**

This indicates a weak negative relationship between discount and order amount in the cleaned dataset.

---

# Part B — Customer Segmentation & Lapse Prediction

## B1. RFM Dataset

RFM analysis was performed using a snapshot date of:

**2025-10-01**

The final RFM dataset contains:

**1,175 customers.**

The three RFM dimensions are:

- **Recency** — how recently the customer purchased
- **Frequency** — number of completed purchases
- **Monetary** — total completed-order spend

---

## B2. RFM Distribution

### Recency

- Minimum = **0**
- Median = **19**
- Maximum = **180**

### Frequency

- Mean = **9.46**
- Maximum = **33**

### Monetary

- Mean = **₹2,552.06**
- Maximum = **₹14,766.55**

These values were used to understand customer purchasing behaviour before clustering.

---

## B3. K-Means Cluster Selection

K-Means clustering was evaluated across:

**K = 2 through K = 8**

Both inertia and silhouette score were considered.

The final selected value was:

**K = 4**

because it provided a strong balance between cluster separation and business interpretability.

A lower inertia at a larger K does not automatically mean that the larger K is better because increasing K generally reduces within-cluster inertia by creating more clusters. Therefore, silhouette quality and business interpretability must also be considered.

Final K=4 silhouette score:

**0.526**

---

## B4. Final Customer Segments

### Occasional

- Customers = **436**
- Mean Recency = **28.86**
- Mean Frequency = **3.77**
- Mean Monetary = **₹1,057.62**

Business interpretation:

These customers purchase occasionally and have relatively low purchase frequency and spending.

Recommended actions:

- Personalized offers
- Category recommendations
- Re-engagement campaigns
- Frequency-building promotions

---

### Premium

- Customers = **138**
- Mean Recency = **24.12**
- Mean Frequency = **6.77**
- Mean Monetary = **₹7,129.70**

Business interpretation:

Premium customers have significantly higher monetary value.

Recommended actions:

- Premium loyalty benefits
- Personalized recommendations
- High-value retention campaigns
- Early access and exclusive offers

---

### Loyal

- Customers = **419**
- Mean Recency = **8.77**
- Mean Frequency = **19.40**
- Mean Monetary = **₹3,410.02**

Business interpretation:

These customers purchase frequently and recently.

Recommended actions:

- Loyalty rewards
- Cross-selling
- Personalized product recommendations
- Retention-focused engagement

---

### At-Risk

- Customers = **182**
- Mean Recency = **109.04**
- Mean Frequency = **2.20**
- Mean Monetary = **₹685.99**

Business interpretation:

These customers have not purchased recently and show relatively low engagement.

Recommended actions:

- Win-back campaigns
- Discount incentives
- Personalized reminders
- Targeted reactivation campaigns

---

## B5. Final Segment Distribution

The final customer distribution is:

- **Occasional — 436**
- **Premium — 138**
- **Loyal — 419**
- **At-Risk — 182**

The segmentation is used to provide customer-level business context for downstream analytics.

---

## B6. Lapse Prediction

A lapse prediction model was developed to identify customers who are at higher risk of becoming inactive.

Final lapse cohort:

**1,156 customers**

Lapsed customers:

**443**

Two candidate models were evaluated.

### Logistic Regression

- F1 score = **0.7236**
- Recall = **0.809**

### Random Forest

- F1 score = **0.7097**
- Recall = **0.742**

Logistic Regression was selected because it achieved better F1 and recall in the evaluated comparison.

---

## B7. Oversampling

Class imbalance was addressed using oversampling.

The resulting recall reached:

**0.9101**

This improved the model's ability to identify potentially lapsed customers.

The final model used:

**Logistic Regression with C = 0.1**

The trained model was saved as:

```text
outputs/lapse_model.joblib
```

---

## B8. Retention List

A retention list was generated using predicted lapse probabilities.

The output is stored at:

```text
outputs/retention_list.csv
```

Example high-risk customers include:

- **C0577 — 0.57496**
- **C0102 — 0.57036**
- **C0697 — 0.54747**
- **C0942 — 0.50992**
- **C0831 — 0.49592**
- **C0509 — 0.47645**
- **C0162 — 0.47641**
- **C0324 — 0.47630**
- **C0977 — 0.44493**
- **C0299 — 0.44472**

These predictions can support targeted retention campaigns.

---

# Part C — Support Ticket Triage & Guardrails

## C1. Ticket Dataset

The support-ticket dataset contains:

**164 tickets**

Input validation identified:

- **4 empty tickets**
- **4 long tickets**
- **156 eligible tickets**

Empty tickets were skipped.

Long tickets were flagged for additional handling instead of being blindly sent through the normal processing path.

---

## C2. PII Redaction

The support pipeline includes privacy-safe preprocessing.

Detected/redacted PII:

- **55 email addresses**
- **91 phone numbers**
- **132 order IDs**

Remaining target PII after redaction:

**0**

The redaction layer helps prevent unnecessary exposure of customer-sensitive information during downstream classification.

---

## C3. Classification

The triage system supports structured JSON output with keyword fallback and invalid-output handling.

Classification results:

- **135 JSON-based classifications**
- **12 keyword-fallback classifications**
- **9 invalid outputs**
- **4 skipped empty tickets**
- **4 flagged long tickets**

The workflow includes validation and retry logic to improve robustness.

---

## C4. Classification Accuracy

Two classification approaches were evaluated.

### Zero-Shot

Accuracy:

**85.7%**

### Few-Shot

Accuracy:

**100%**

The few-shot approach produced the strongest evaluated classification result.

---

## C5. Routing

Support tickets were routed into:

- **support_queue — 102**
- **security_team — 34**
- **human_review — 17**
- **premium_desk — 11**

This routing combines ticket classification with customer context and operational handling rules.

---

## C6. Priority

Ticket priority distribution:

- **NORMAL — 119**
- **HIGH — 45**

Priority is used as an additional operational signal for support handling.

---

## C7. Token Usage and Retries

Final support processing recorded:

- Total tokens = **24,220**
- Retries = **19**

The workflow demonstrates controlled retries and token-budget-aware processing.

---

## C8. Token Budget Demonstration

A separate token-budget demonstration used:

**6,000 token budget**

Results:

- **81 tickets processed**
- Actual usage = **6,032 tokens**

The demonstration shows how processing can stop or constrain work when the configured budget is reached.

---

## C9. Support Output

Final triage results are stored in:

```text
outputs/triage_results.csv
```

The budget demonstration is stored in:

```text
outputs/triage_budget_demo.csv
```

---

# Part D — Policy RAG & Refund Agent

## D1. Policy Knowledge Base

The RAG workflow uses:

**5 policy documents**

The policy documents cover:

- Delivery
- Escalation
- Payment
- Privacy
- Refund

The documents are divided into:

**15 chunks**

The TF-IDF representation contains:

**15 × 200 dimensions**

---

## D2. Retrieval Evaluation

The RAG evaluation produced:

- Document retrieval = **12/12**
- Fact retrieval = **12/12**
- Fallback cases = **2/2**
- Zero-overlap fact retrieval = **10/12**

The retrieval system combines similarity-based retrieval with fallback behaviour for cases where direct retrieval overlap is weak.

---

## D3. Available Tools

The refund agent uses the following tools:

```text
get_order
search_policy
calculate_refund
issue_refund
escalate_to_human
```

Each tool has a specific responsibility in the workflow.

---

## D4. ReAct Workflow

The agent follows a reasoning-and-action workflow where it:

1. Receives the customer request.
2. Retrieves order information.
3. Searches the relevant policy.
4. Calculates the eligible refund.
5. Determines whether human approval is required.
6. Issues the refund when permitted.
7. Escalates when the policy or scenario requires human review.

---

## D5. Seven Scenario Evaluation

The agent was evaluated using **7 ReAct scenarios**.

The scenarios covered:

- Valid refund requests
- Policy-based refund calculation
- Human approval requirements
- Invalid or unsupported requests
- Escalation behaviour
- Maximum-iteration fallback
- Tool/workflow execution

All seven scenarios were completed according to the expected workflow outcomes.

---

## D6. Example Refund Scenario

Scenario S1 used:

```text
Order ID: ORD-100048
```

Calculated refund:

**₹128.25**

The workflow successfully completed the refund process.

Final S1 result:

```text
REFUND 128.25
```

---

## D7. Human Approval Scenario

Scenario S3 used:

```text
Order ID: ORD-100145
```

Calculated refund:

**₹1,999**

The scenario required:

**Human approval**

The agent correctly identified the need for human intervention instead of automatically completing the refund.

---

## D8. Maximum Iteration Fallback

Scenario S7 demonstrated the maximum-iteration protection.

The system supports:

```text
FALLBACK_MAX_ITERATIONS
```

This prevents an agent from continuing indefinitely when it cannot reach a valid final action.

---

## D9. Checkpoint and Resume

The project includes a checkpoint/resume demonstration.

The workflow can preserve execution state and resume after an interruption instead of restarting the complete workflow from the beginning.

The checkpoint demonstration is stored under:

```text
state/
```

Execution information is recorded in:

```text
outputs/agent_runs.jsonl
```

---

## D10. Crash/Resume Tool Sequence

The successful S1 tool sequence demonstrates the intended tool execution order:

```text
get_order
    ↓
search_policy
    ↓
calculate_refund
    ↓
issue_refund
```

Exactly these four tool executions were required for the successful refund flow.

The final result was:

```text
REFUND 128.25
```

---

## D11. Refund Ledger

Refund operations are recorded in:

```text
outputs/refund_ledger.jsonl
```

The current ledger contains:

**25 records**

This provides an auditable record of refund-related tool actions.

---

## D12. ReAct vs Plan-and-Execute

The project uses a ReAct-style approach because customer-support refund decisions may require dynamic interaction with:

- Order data
- Policy documents
- Refund calculations
- Approval requirements
- Escalation rules

A rigid plan-and-execute workflow can be less flexible when the next action depends on information retrieved during execution.

The ReAct approach allows the agent to select the next tool based on the current state of the workflow.

---

# End-to-End Workflow

```text
Raw Data
   ↓
Data Validation
   ↓
Data Cleaning
   ↓
SQLite Analytical Database
   ↓
SQL Analysis + EDA
   ↓
RFM Customer Segmentation
   ↓
Lapse Prediction
   ↓
Support Ticket Guardrails
   ↓
PII Redaction
   ↓
Ticket Classification
   ↓
Support Routing
   ↓
Policy RAG
   ↓
Tool-Using Refund Agent
   ↓
Refund / Escalation
```

The workflow connects traditional analytics and machine learning with privacy-aware AI support automation.

---

# Key Project Results

The project successfully demonstrates an offline end-to-end workflow across customer analytics and AI-assisted support.

### Customer Analytics

- **1,200 customers**
- **12,309 distinct cleaned orders**
- **11,110 completed orders**
- **₹29.99L completed-order revenue**
- **6 normalized cities**
- **5 product categories**

### Customer Intelligence

- **1,175 RFM customers**
- **4 customer segments**
- **0.526 silhouette score**
- **443 lapsed customers**
- Logistic Regression F1 = **0.7236**
- Logistic Regression recall = **0.809**
- Oversampling recall = **0.9101**

### Support Intelligence

- **164 tickets**
- **156 eligible tickets**
- **55 email redactions**
- **91 phone redactions**
- **132 order-ID redactions**
- **0 remaining target PII**
- Zero-shot accuracy = **85.7%**
- Few-shot accuracy = **100%**

### AI Support Agent

- **5 policy documents**
- **15 policy chunks**
- Document retrieval = **12/12**
- Fact retrieval = **12/12**
- **7 ReAct scenarios**
- **25 refund ledger records**
- Successful S1 refund = **₹128.25**
- Human-approval scenario = **₹1,999**

---

# Privacy & Safety

The project is designed as an offline demonstration and does not require live customer data or production customer credentials.

Privacy-related controls include:

- PII detection
- Email redaction
- Phone-number redaction
- Order-ID redaction
- Empty-input guardrails
- Long-input handling
- Structured output validation
- Retry controls
- Token-budget controls
- Maximum-iteration protection
- Human escalation

The project uses synthetic/offline data for reproducibility and demonstration purposes.

---

# Limitations

This project is an offline capstone implementation and is not a production customer-support system.

Current limitations include:

- Offline/mock LLM behaviour
- Synthetic or controlled datasets
- TF-IDF retrieval rather than a production vector database
- No live payment gateway
- No real customer account integration
- No production authentication system
- No production monitoring infrastructure
- No live CRM integration
- Model performance is based on the provided evaluation dataset

The system should therefore be considered an **analytics and AI demonstration system**, not a production operational platform.

---

# Next Steps

Potential future improvements include:

- Replace mock LLM calls with a production LLM provider.
- Replace TF-IDF retrieval with a production vector database such as ChromaDB.
- Add embedding-based semantic retrieval.
- Add real-time order and customer APIs.
- Add authentication and role-based access.
- Add production monitoring and logging.
- Add automated model retraining.
- Add advanced customer lifetime value prediction.
- Add real-time churn/lapse scoring.
- Add multilingual support.
- Add production-grade agent observability.
- Integrate the system with a production CRM/support platform.

---

# Conclusion

The **Instamart Customer Intelligence & Support Copilot** demonstrates how customer analytics, machine learning, data engineering, privacy-aware ticket processing, RAG, and tool-using AI agents can be combined into a single end-to-end workflow.

The project moves from:

**raw data → cleaned analytical data → business insights → customer segmentation → lapse prediction → support triage → policy retrieval → automated refund decisioning → refund/escalation**

The final solution provides both **business intelligence** and **AI-assisted customer support capabilities** while remaining reproducible and suitable for an offline capstone environment.
