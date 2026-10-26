-- Inspect the source before building features.
-- This script is read-only and does not require the destination dataset.

-- 1. Status distribution: confirms the exact value used for completed sales.
SELECT
  status,
  COUNT(*) AS item_rows,
  COUNT(DISTINCT order_id) AS orders,
  ROUND(SUM(COALESCE(sale_price, 0)), 2) AS gross_item_value
FROM `bigquery-public-data.thelook_ecommerce.order_items`
GROUP BY status
ORDER BY item_rows DESC;

-- 2. Source date coverage.
SELECT
  MIN(DATE(created_at)) AS first_order_item_date,
  MAX(DATE(created_at)) AS last_order_item_date,
  COUNT(*) AS item_rows,
  COUNT(DISTINCT order_id) AS distinct_orders,
  COUNT(DISTINCT user_id) AS distinct_customers
FROM `bigquery-public-data.thelook_ecommerce.order_items`;

-- 3. Rows that would fail the pipeline's core validity rules.
SELECT
  COUNTIF(user_id IS NULL) AS null_customer_rows,
  COUNTIF(order_id IS NULL) AS null_order_rows,
  COUNTIF(sale_price IS NULL) AS null_price_rows,
  COUNTIF(sale_price <= 0) AS non_positive_price_rows,
  COUNTIF(created_at IS NULL) AS null_created_at_rows,
  COUNTIF(status = 'Complete') AS completed_item_rows
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE DATE(created_at) <= DATE '2026-09-30';

-- 4. Check whether the item identifier is unique. If duplicate_ids is not 0,
-- ROW_NUMBER in the build script keeps one deterministic row per item ID.
SELECT
  COUNT(*) AS item_rows,
  COUNT(DISTINCT id) AS distinct_item_ids,
  COUNT(*) - COUNT(DISTINCT id) AS duplicate_ids
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE DATE(created_at) <= DATE '2026-09-30';

