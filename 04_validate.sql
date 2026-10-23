-- Materialize data-quality checks as portfolio evidence.
-- Replace `your-gcp-project` before running.

CREATE OR REPLACE TABLE
  `your-gcp-project.rfm_customer_segmentation.data_quality_checks` AS
WITH
metrics AS (
  SELECT *
  FROM `your-gcp-project.rfm_customer_segmentation.customer_rfm_metrics`
),
segments AS (
  SELECT *
  FROM `your-gcp-project.rfm_customer_segmentation.customer_segments`
),
checks AS (
  SELECT
    1 AS check_order,
    'unique_customer_id' AS check_name,
    COUNT(*) - COUNT(DISTINCT user_id) AS failed_rows
  FROM segments

  UNION ALL

  SELECT
    2,
    'required_fields_not_null',
    COUNTIF(
      user_id IS NULL
      OR last_order_date IS NULL
      OR recency_days IS NULL
      OR frequency IS NULL
      OR monetary_value IS NULL
      OR r_score IS NULL
      OR f_score IS NULL
      OR m_score IS NULL
      OR rfm_code IS NULL
      OR segment IS NULL
    )
  FROM segments

  UNION ALL

  SELECT
    3,
    'positive_customer_metrics',
    COUNTIF(recency_days < 0 OR frequency <= 0 OR monetary_value <= 0)
  FROM segments

  UNION ALL

  SELECT
    4,
    'rfm_scores_in_range',
    COUNTIF(
      r_score NOT BETWEEN 1 AND 5
      OR f_score NOT BETWEEN 1 AND 5
      OR m_score NOT BETWEEN 1 AND 5
    )
  FROM segments

  UNION ALL

  SELECT
    5,
    'valid_rfm_code',
    COUNTIF(NOT REGEXP_CONTAINS(rfm_code, r'^[1-5]{3}$'))
  FROM segments

  UNION ALL

  SELECT
    6,
    'known_segment',
    COUNTIF(segment NOT IN (
      'Champions',
      'Loyal Customers',
      'High Value',
      'Potential Loyalists',
      'New Customers',
      'Promising',
      'Needs Attention',
      'Can''t Lose Them',
      'At Risk',
      'Hibernating'
    ))
  FROM segments

  UNION ALL

  SELECT
    7,
    'metric_to_segment_row_reconciliation',
    ABS(
      (SELECT COUNT(*) FROM metrics)
      - (SELECT COUNT(*) FROM segments)
    )

  UNION ALL

  SELECT
    8,
    'metric_to_segment_value_reconciliation',
    IF(
      ABS(
        (SELECT SUM(monetary_value) FROM metrics)
        - (SELECT SUM(monetary_value) FROM segments)
      ) < 0.01,
      0,
      1
    )
)
SELECT
  check_order,
  check_name,
  failed_rows,
  IF(failed_rows = 0, 'PASS', 'FAIL') AS status,
  CURRENT_TIMESTAMP() AS checked_at
FROM checks
ORDER BY check_order;

-- The result grid should show eight PASS rows.
SELECT
  check_order,
  check_name,
  failed_rows,
  status,
  checked_at
FROM `your-gcp-project.rfm_customer_segmentation.data_quality_checks`
ORDER BY check_order;

