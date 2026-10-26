-- Create a compact analytics layer for Power BI.
-- Replace `your-gcp-project` before running.

CREATE OR REPLACE VIEW
  `your-gcp-project.rfm_customer_segmentation.v_customer_rfm` AS
SELECT
  user_id,
  analysis_date,
  last_order_date,
  recency_days,
  frequency,
  monetary_value,
  average_order_value,
  purchased_items,
  r_score,
  f_score,
  m_score,
  rfm_code,
  rfm_average,
  segment
FROM `your-gcp-project.rfm_customer_segmentation.customer_segments`;

CREATE OR REPLACE VIEW
  `your-gcp-project.rfm_customer_segmentation.v_segment_summary` AS
WITH summary AS (
  SELECT
    segment,
    COUNT(*) AS customers,
    ROUND(SUM(monetary_value), 2) AS revenue,
    SUM(frequency) AS orders,
    ROUND(AVG(recency_days), 1) AS average_recency_days,
    ROUND(AVG(frequency), 2) AS average_orders_per_customer,
    ROUND(AVG(monetary_value), 2) AS average_revenue_per_customer
  FROM `your-gcp-project.rfm_customer_segmentation.customer_segments`
  GROUP BY segment
)
SELECT
  summary.*,
  ROUND(100 * SAFE_DIVIDE(customers, SUM(customers) OVER ()), 2)
    AS customer_share_pct,
  ROUND(100 * SAFE_DIVIDE(revenue, SUM(revenue) OVER ()), 2)
    AS revenue_share_pct
FROM summary;

CREATE OR REPLACE VIEW
  `your-gcp-project.rfm_customer_segmentation.v_monthly_sales_by_segment` AS
WITH deduplicated_items AS (
  SELECT * EXCEPT (row_number)
  FROM (
    SELECT
      oi.order_item_id,
      oi.order_id,
      oi.user_id,
      oi.sale_price,
      DATE(oi.created_at) AS order_date,
      oi.status,
      ROW_NUMBER() OVER (
        PARTITION BY oi.order_item_id
        ORDER BY oi.created_at DESC, oi.order_id DESC
      ) AS row_number
    FROM `your-gcp-project.rfm_customer_segmentation.stg_order_items_snapshot` AS oi
    WHERE DATE(oi.created_at) <= DATE '2026-09-30'
  )
  WHERE row_number = 1
),
valid_items AS (
  SELECT
    order_item_id,
    order_id,
    user_id,
    order_date,
    CAST(sale_price AS NUMERIC) AS sale_price
  FROM deduplicated_items
  WHERE user_id IS NOT NULL
    AND order_id IS NOT NULL
    AND sale_price > 0
    AND status = 'Complete'
)
SELECT
  DATE_TRUNC(items.order_date, MONTH) AS order_month,
  segments.segment,
  COUNT(DISTINCT items.order_id) AS orders,
  COUNT(DISTINCT items.user_id) AS purchasing_customers,
  COUNT(DISTINCT items.order_item_id) AS items,
  ROUND(SUM(items.sale_price), 2) AS revenue
FROM valid_items AS items
INNER JOIN `your-gcp-project.rfm_customer_segmentation.customer_segments` AS segments
  USING (user_id)
GROUP BY order_month, segments.segment;

