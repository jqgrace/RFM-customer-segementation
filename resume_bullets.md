# Resume bullets by completion stage

Use only the version supported by work you have actually completed. Replace
bracketed placeholders with observed values; never estimate them.

## Stage A — code written, not yet executed

**RFM Customer Segmentation Analysis | BigQuery SQL**

- Developed a version-controlled BigQuery SQL pipeline that transforms public
  e-commerce order-item data into customer-level recency, frequency, and
  monetary features using staged CTEs and explicit grain control.
- Implemented deterministic deduplication and quintile scoring with
  `ROW_NUMBER()` and `NTILE()`, then translated RFM patterns into mutually
  exclusive customer segments through ordered `CASE` logic.
- Added SQL data-quality checks for primary-key uniqueness, nulls, valid score
  ranges, segment coverage, and row/value reconciliation prior to reporting.

## Stage B — BigQuery pipeline executed and validated

**RFM Customer Segmentation Analysis | BigQuery SQL**

- Built and validated a reproducible BigQuery pipeline over theLook e-commerce
  data, aggregating `[ORDER_ITEM_ROWS]` order-item records into `[CUSTOMERS]`
  customer-level RFM profiles as of October 1, 2026.
- Used CTEs, `ROW_NUMBER()`, and `NTILE()` window functions to clean transaction
  data, control order/customer grain, and assign recency, frequency, and
  monetary quintiles; achieved `[PASSED]/8` SQL quality checks.
- Encoded ten actionable customer segments with ordered `CASE` logic and
  identified `[TOP_SEGMENT]` as the largest revenue segment at `[REVENUE_SHARE]%`
  of completed-sales value.

## Stage C — BigQuery and Power BI completed

**RFM Customer Segmentation Analysis | BigQuery SQL, Power BI**

- Built a reproducible BigQuery feature pipeline that converted
  `[ORDER_ITEM_ROWS]` public e-commerce order-item records into `[CUSTOMERS]`
  validated customer RFM profiles using CTEs, grain-aware aggregation, and
  `ROW_NUMBER()` window logic.
- Applied `NTILE()` quintile scoring and ordered `CASE` rules to create ten
  mutually exclusive business segments; reconciled customer counts and
  `[REVENUE]` in completed-sales value across `[PASSED]/8` automated SQL checks.
- Designed a Power BI report backed by curated BigQuery views to compare segment
  mix, revenue contribution, purchase frequency, and monthly sales patterns,
  highlighting `[TOP_SEGMENT]` at `[REVENUE_SHARE]%` of represented revenue.

## Data Scientist application: compact two-bullet version

Use this after Stage C if resume space is limited:

- Engineered customer-level behavioral features in BigQuery from
  `[ORDER_ITEM_ROWS]` order-item records, using CTEs, grain-aware aggregation,
  and window functions to produce `[CUSTOMERS]` validated RFM profiles.
- Converted RFM quintiles into ten interpretable segments with ordered `CASE`
  logic and surfaced segment mix, revenue concentration, and temporal patterns
  in Power BI; verified the pipeline with `[PASSED]/8` SQL quality checks.

## Claims to avoid

Do not write that the project:

- increased retention, revenue, or conversion without a real intervention and
  measured post-period;
- processed “millions” of rows unless the query result proves it;
- automated refreshes unless a schedule is configured and tested;
- predicts churn or lifetime value—the current project is descriptive,
  rule-based segmentation;
- used Power BI until the report exists and its totals reconcile to BigQuery.

