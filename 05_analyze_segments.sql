-- Answer the main business questions after all validation checks pass.
-- Replace `your-gcp-project` before running.

-- 1. Segment size, revenue contribution, and purchase behavior.
WITH segment_summary AS (
  SELECT
    segment,
    COUNT(*) AS customers,
    ROUND(SUM(monetary_value), 2) AS revenue,
    SUM(frequency) AS orders,
    ROUND(AVG(recency_days), 1) AS average_recency_days,
    ROUND(AVG(frequency), 2) AS average_orders_per_customer,
    ROUND(AVG(monetary_value), 2) AS average_revenue_per_customer,
    ROUND(SAFE_DIVIDE(SUM(monetary_value), SUM(frequency)), 2)
      AS revenue_per_order
  FROM `your-gcp-project.rfm_customer_segmentation.customer_segments`
  GROUP BY segment
)
SELECT
  segment_summary.*,
  ROUND(
    100 * SAFE_DIVIDE(customers, SUM(customers) OVER ()),
    2
  ) AS customer_share_pct,
  ROUND(
    100 * SAFE_DIVIDE(revenue, SUM(revenue) OVER ()),
    2
  ) AS revenue_share_pct,
  DENSE_RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM segment_summary
ORDER BY revenue DESC;

-- 2. Prioritized, anonymous action list. No names or emails are exposed.
SELECT
  user_id,
  segment,
  recency_days,
  frequency,
  monetary_value,
  rfm_code,
  CASE
    WHEN segment = 'Can''t Lose Them' THEN 'High-priority win-back'
    WHEN segment = 'At Risk' THEN 'Targeted reactivation'
    WHEN segment = 'Champions' THEN 'Reward and referral'
    WHEN segment = 'Loyal Customers' THEN 'Cross-sell and loyalty benefit'
    WHEN segment IN ('Potential Loyalists', 'Promising', 'New Customers')
      THEN 'Next-purchase nurture'
    ELSE 'Low-cost engagement'
  END AS recommended_action
FROM `your-gcp-project.rfm_customer_segmentation.customer_segments`
ORDER BY
  CASE segment
    WHEN 'Can''t Lose Them' THEN 1
    WHEN 'At Risk' THEN 2
    WHEN 'Champions' THEN 3
    WHEN 'Loyal Customers' THEN 4
    ELSE 5
  END,
  monetary_value DESC
LIMIT 100;

