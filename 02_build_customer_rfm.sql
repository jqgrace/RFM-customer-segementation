-- Freeze the observation window, then build one validated RFM row per customer.
-- Replace `your-gcp-project` before running.

CREATE OR REPLACE TABLE
  `your-gcp-project.rfm_customer_segmentation.stg_order_items_snapshot`
OPTIONS (
  description = 'theLook order items extracted through 2024-12-31'
) AS
SELECT
  oi.id AS order_item_id,
  oi.order_id,
  oi.user_id,
  oi.product_id,
  oi.status,
  CAST(oi.sale_price AS NUMERIC) AS sale_price,
  oi.created_at,
  oi.delivered_at,
  oi.returned_at,
  CURRENT_TIMESTAMP() AS source_extracted_at
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
WHERE DATE(oi.created_at) <= DATE '2024-12-31';

CREATE OR REPLACE TABLE
  `your-gcp-project.rfm_customer_segmentation.customer_rfm_metrics`
CLUSTER BY user_id AS
WITH
parameters AS (
  SELECT
    DATE '2024-12-31' AS cutoff_date,
    DATE '2025-01-01' AS analysis_date
),

-- Select only fields used downstream and apply the fixed observation window.
source_items AS (
  SELECT
    oi.order_item_id,
    oi.order_id,
    oi.user_id,
    oi.product_id,
    oi.status,
    oi.sale_price,
    oi.created_at,
    oi.delivered_at,
    oi.returned_at
  FROM `your-gcp-project.rfm_customer_segmentation.stg_order_items_snapshot` AS oi
  CROSS JOIN parameters AS p
  WHERE DATE(oi.created_at) <= p.cutoff_date
),

-- Defensive deduplication. The public table normally has unique item IDs; the
-- explicit tie-breakers keep the rule deterministic if that assumption changes.
deduplicated_items AS (
  SELECT * EXCEPT (row_number)
  FROM (
    SELECT
      source_items.*,
      ROW_NUMBER() OVER (
        PARTITION BY order_item_id
        ORDER BY created_at DESC, order_id DESC
      ) AS row_number
    FROM source_items
  )
  WHERE row_number = 1
),

-- Count only completed, positive-value purchases with usable customer keys.
valid_items AS (
  SELECT
    order_item_id,
    order_id,
    user_id,
    product_id,
    sale_price,
    DATE(created_at) AS order_date
  FROM deduplicated_items
  WHERE user_id IS NOT NULL
    AND order_id IS NOT NULL
    AND created_at IS NOT NULL
    AND sale_price > 0
    AND status = 'Complete'
),

-- Establish the correct order grain before computing customer frequency.
order_totals AS (
  SELECT
    user_id,
    order_id,
    MIN(order_date) AS order_date,
    COUNT(DISTINCT order_item_id) AS items_in_order,
    ROUND(SUM(sale_price), 2) AS order_value
  FROM valid_items
  GROUP BY user_id, order_id
),

customer_metrics AS (
  SELECT
    user_id,
    MAX(order_date) AS last_order_date,
    COUNT(DISTINCT order_id) AS frequency,
    ROUND(SUM(order_value), 2) AS monetary_value,
    ROUND(AVG(order_value), 2) AS average_order_value,
    SUM(items_in_order) AS purchased_items
  FROM order_totals
  GROUP BY user_id
)

SELECT
  cm.user_id,
  p.analysis_date,
  cm.last_order_date,
  DATE_DIFF(p.analysis_date, cm.last_order_date, DAY) AS recency_days,
  cm.frequency,
  cm.monetary_value,
  cm.average_order_value,
  cm.purchased_items
FROM customer_metrics AS cm
CROSS JOIN parameters AS p;

