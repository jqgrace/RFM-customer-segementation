# Power BI build guide

Build the report only after `data_quality_checks` shows eight `PASS` rows.

## Connect

1. In Power BI Desktop, choose **Get data > Google BigQuery**.
2. Sign in and select your project.
3. Choose the `rfm_customer_segmentation` dataset.
4. Import these views:
   - `v_customer_rfm`
   - `v_segment_summary`
   - `v_monthly_sales_by_segment`
5. Use Import mode for a small portfolio report. Record the refresh date.

The three views are already aggregated for their intended visuals. Do not
create relationships between them unless a visual specifically requires one;
mixing their grains can double-count revenue.

## Measures

Create these measures in the `v_customer_rfm` table:

```DAX
Customers = DISTINCTCOUNT(v_customer_rfm[user_id])

Customer Revenue = SUM(v_customer_rfm[monetary_value])

Customer Orders = SUM(v_customer_rfm[frequency])

Average Customer Value =
DIVIDE([Customer Revenue], [Customers])

Average Order Value =
DIVIDE([Customer Revenue], [Customer Orders])

Revenue Share =
DIVIDE(
    [Customer Revenue],
    CALCULATE([Customer Revenue], ALL(v_customer_rfm[segment]))
)
```

Format revenue measures as currency and `Revenue Share` as a percentage.

## Recommended report page

### Top row: KPI cards

- Customers
- Customer Revenue
- Customer Orders
- Average Order Value

### Main visuals

1. **Revenue and customer share by segment** — clustered bar chart using
   `v_segment_summary`; compare `revenue_share_pct` with `customer_share_pct`.
2. **RFM score heatmap** — matrix with `r_score` as rows, `f_score` as columns,
   and Customers as values; apply conditional color formatting.
3. **Monthly revenue by segment** — line chart using
   `v_monthly_sales_by_segment[order_month]`, `segment`, and `revenue`.
4. **Customer action table** — `segment`, `recency_days`, `frequency`,
   `monetary_value`, and `rfm_code`; keep `user_id` anonymous.

### Slicers

- Segment
- R score
- F score
- M score

## Design checks

- Use one color consistently for each segment across charts.
- Show the fixed analysis date (`2025-01-01`) in the subtitle.
- Include a note that the data is synthetic and public.
- Confirm total customers and revenue match the BigQuery segment query.
- Avoid maps or demographic charts unless they answer the business question.

## Portfolio evidence

Save a clean screenshot as `images/rfm_dashboard.png` and add it to the README.
Record the BigQuery totals first, then verify the Power BI cards match exactly.

