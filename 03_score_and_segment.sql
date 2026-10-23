-- Score customers by relative quintile and assign one ordered CASE segment.
-- Replace `your-gcp-project` before running.

CREATE OR REPLACE TABLE
  `your-gcp-project.rfm_customer_segmentation.customer_segments`
CLUSTER BY segment AS
WITH quintiles AS (
  SELECT
    metrics.*,
    -- Lower recency is better, so the ascending tile is reversed.
    6 - NTILE(5) OVER (
      ORDER BY recency_days ASC, user_id ASC
    ) AS r_score,
    NTILE(5) OVER (
      ORDER BY frequency ASC, user_id ASC
    ) AS f_score,
    NTILE(5) OVER (
      ORDER BY monetary_value ASC, user_id ASC
    ) AS m_score
  FROM `your-gcp-project.rfm_customer_segmentation.customer_rfm_metrics` AS metrics
),
scored AS (
  SELECT
    quintiles.*,
    FORMAT('%d%d%d', r_score, f_score, m_score) AS rfm_code,
    ROUND((r_score + f_score + m_score) / 3.0, 2) AS rfm_average
  FROM quintiles
)
SELECT
  scored.*,
  CASE
    WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4
      THEN 'Champions'
    WHEN r_score >= 3 AND f_score >= 4
      THEN 'Loyal Customers'
    WHEN r_score >= 3 AND m_score >= 4
      THEN 'High Value'
    WHEN r_score >= 4 AND f_score BETWEEN 2 AND 3
      THEN 'Potential Loyalists'
    WHEN r_score = 5 AND f_score = 1
      THEN 'New Customers'
    WHEN r_score = 4 AND f_score = 1
      THEN 'Promising'
    WHEN r_score = 3 AND f_score BETWEEN 2 AND 3
      THEN 'Needs Attention'
    WHEN r_score <= 2 AND f_score >= 4 AND m_score >= 4
      THEN 'Can''t Lose Them'
    WHEN r_score <= 2 AND f_score >= 3
      THEN 'At Risk'
    ELSE 'Hibernating'
  END AS segment
FROM scored;

