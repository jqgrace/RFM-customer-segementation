# RFM Customer Segmentation in BigQuery

An end-to-end, SQL-first customer analytics project built on the public
[`bigquery-public-data.thelook_ecommerce`](https://cloud.google.com/bigquery/docs/gemini-analyze-data)
dataset. The project turns order-item records into validated customer-level RFM
features and business-ready segments, then exposes clean views for Power BI.

> Portfolio status (update this honestly as you work):
>
> - [x] SQL pipeline, validation queries, and documentation created
> - [ ] Queries executed successfully in the project owner's BigQuery account
> - [ ] Query outputs and validation counts recorded below
> - [ ] Power BI report built and screenshots added

## Business question

Which customers should the business retain, reward, or reactivate based on how
recently, how often, and how much they purchased?

## What this project demonstrates

- Multi-stage feature engineering with readable CTEs
- Grain control: order-item rows are aggregated to one row per order before
  customer metrics are calculated
- Window functions: `ROW_NUMBER()` for deterministic deduplication and
  `NTILE(5)` for relative RFM scoring
- Mutually exclusive business segments implemented with ordered `CASE` logic
- SQL data-quality tests for uniqueness, nulls, score ranges, reconciliation,
  and segment coverage
- Analytics views designed for a star-schema-style Power BI report

## Architecture

```text
theLook order_items (public data)
            |
            v
fixed-window source snapshot
            |
            v
filter + deterministic deduplication
            |
            v
one row per order --> one row per customer (R, F, M)
            |
            v
quintile scores --> CASE segments --> validation tests
            |
            v
customer, segment, and monthly-sales views --> Power BI
```

## Repository structure

```text
.
|-- sql/
|   |-- 00_setup.sql
|   |-- 01_profile_source.sql
|   |-- 02_build_customer_rfm.sql
|   |-- 03_score_and_segment.sql
|   |-- 04_validate.sql
|   |-- 05_analyze_segments.sql
|   `-- 06_power_bi_views.sql
|-- docs/
|   |-- data_dictionary.md
|   |-- github_bigquery_setup_zh.md
|   |-- guide_zh.md
|   |-- power_bi.md
|   `-- resume_bullets.md
`-- README.md
```

New to GitHub or BigQuery? Follow the
[`GitHub + BigQuery Chinese setup guide`](docs/github_bigquery_setup_zh.md).

## Reproduce the analysis

### Prerequisites

- A Google Cloud project with BigQuery enabled
- Permission to create a dataset, tables, and views
- Query location set to **US**, where the public dataset is hosted
- Optional: Power BI Desktop for the dashboard stage

BigQuery public datasets are publicly readable, but query processing is billed
to your Google Cloud project. Check the query estimator before running a query.

### Run order

1. Replace every instance of `your-gcp-project` in the SQL files with your own
   Google Cloud project ID.
2. Run [`sql/00_setup.sql`](sql/00_setup.sql).
3. Run [`sql/01_profile_source.sql`](sql/01_profile_source.sql) and inspect the
   source statuses, date range, and invalid-row counts.
4. Run [`sql/02_build_customer_rfm.sql`](sql/02_build_customer_rfm.sql).
5. Run [`sql/03_score_and_segment.sql`](sql/03_score_and_segment.sql).
6. Run [`sql/04_validate.sql`](sql/04_validate.sql). Do not publish results
   until every required check returns `PASS`.
7. Run [`sql/05_analyze_segments.sql`](sql/05_analyze_segments.sql) and record
   the results below.
8. Run [`sql/06_power_bi_views.sql`](sql/06_power_bi_views.sql), then follow
   [`docs/power_bi.md`](docs/power_bi.md).

The pipeline uses a fixed analysis cutoff of **2026-09-30**. Purchases after
that date are excluded, and recency is measured as of **2026-10-01**. Keeping
this date fixed makes portfolio results comparable. File 02 also materializes
the filtered source rows into the project dataset, so all downstream outputs in
one project run use the same extracted data. Re-running file 02 refreshes that
snapshot; because the public source is maintained upstream, exact counts may
change if its historical records change. If the source does not contain enough
valid records before the cutoff, profile the data first and change the date
consistently in files 02 and 06.

## Metric definitions

| Metric | Definition |
|---|---|
| Recency | Days between a customer's latest completed purchase and 2026-10-01 |
| Frequency | Count of distinct completed orders through 2026-09-30 |
| Monetary | Sum of positive `sale_price` across completed order items |
| R/F/M score | Relative quintile from 1 (lowest) to 5 (highest/best) |
| RFM code | Three-character concatenation of R, F, and M scores |

Only rows with non-null customer and order IDs, positive sale prices, and a
`Complete` status enter the model. Returned, cancelled, processing, and shipped
items are excluded from realized revenue.

## Segmentation rules

Rules are evaluated top to bottom, so every customer receives exactly one
segment.

| Segment | Rule summary | Suggested action |
|---|---|---|
| Champions | Recent, frequent, and high value | Reward and request referrals |
| Loyal Customers | Recent-to-moderate recency and high frequency | Cross-sell and recognize loyalty |
| High Value | Recent-to-moderate recency and high spend | Protect margin and personalize offers |
| Potential Loyalists | Recent with moderate frequency | Encourage the next purchase |
| New Customers | Most recent, one-purchase customers | Improve onboarding |
| Promising | Recent, low-frequency customers | Nurture with relevant content |
| Needs Attention | Mid-recency and moderate frequency | Send targeted reminders |
| Can't Lose Them | Lapsed, frequent, high-value customers | Prioritize win-back outreach |
| At Risk | Lapsed but historically frequent | Run reactivation campaigns |
| Hibernating | Lapsed and low-frequency | Use low-cost re-engagement |

## Results

Fill this section only after executing the queries and saving evidence.

### Frozen snapshot results through 2026-09-30

| Source check | Observed value |
|---|---:|
| Snapshot order-item rows | 168,434 |
| Completed order-item rows | 42,030 |
| Completed orders | 29,071 |
| Valid RFM customers | 25,765 |
| Completed-sales value | $2,521,344.71 |

The snapshot was extracted on 2026-10-24. The customer metrics reconcile exactly
to its completed rows, orders, and customers. Earlier exploratory counts changed
when the upstream synthetic public table refreshed, demonstrating why the
materialized snapshot is necessary for reproducible downstream results.

| Result | Value |
|---|---:|
| Valid customers | 25,765 |
| Valid completed orders | 29,071 |
| Revenue represented | $2,521,344.71 |
| Largest segment | `TBD` |
| Highest-revenue segment | `TBD` |
| Validation checks passed | `TBD / 8` |

## Limitations

- theLook is synthetic public e-commerce data; recommendations demonstrate the
  method rather than a real company's causal business impact.
- Quintiles are relative to the selected customer population and cutoff date.
- `NTILE` keeps quintile sizes similar, so customers tied on frequency or value
  can receive adjacent scores; `user_id` provides a deterministic tie-breaker.
- Re-running the snapshot step can change counts if the upstream public dataset
  has changed, even though the observation cutoff stays fixed.
- `sale_price` is treated as realized revenue; discounts, tax, shipping, and
  cost are outside the available transaction definition.
- This is a current-state segmentation, not a causal retention model or a
  forecast of customer lifetime value.

## Next extensions

- Store monthly RFM snapshots and measure segment migration
- Add cohort retention features
- Compare rule-based segments with clustering after sufficient validation
- Automate scheduled refreshes with Dataform or BigQuery scheduled queries

## Source

Google Cloud's BigQuery Public Datasets program hosts the source dataset. The
project uses GoogleSQL and fully qualified public table names.

