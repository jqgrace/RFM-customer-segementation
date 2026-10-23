# Data dictionary

## Source table

`bigquery-public-data.thelook_ecommerce.order_items`

Only the fields needed for this project are selected. The project never uses
customer names, emails, or street addresses.

| Source field | Use |
|---|---|
| `id` | Order-item key used for deterministic deduplication |
| `order_id` | Distinct-order grain for frequency |
| `user_id` | Anonymous customer key |
| `product_id` | Retained for possible product extensions |
| `status` | Restricts realized purchases to `Complete` |
| `sale_price` | Item-level monetary value |
| `created_at` | Purchase date and observation-window filter |
| `delivered_at` | Profiled/retained for future lifecycle checks |
| `returned_at` | Profiled/retained for future lifecycle checks |

## `stg_order_items_snapshot`

A materialized copy of the selected source fields through the fixed cutoff date.
It records `source_extracted_at` so the project can show when its input snapshot
was refreshed. `sale_price` is cast to `NUMERIC` for exact currency arithmetic.

## `customer_rfm_metrics`

One row per `user_id`.

| Field | Type | Definition |
|---|---|---|
| `user_id` | INTEGER | Anonymous customer key |
| `analysis_date` | DATE | Fixed date on which recency is measured |
| `last_order_date` | DATE | Latest valid completed purchase date |
| `recency_days` | INTEGER | Days since the latest valid purchase |
| `frequency` | INTEGER | Distinct valid completed orders |
| `monetary_value` | NUMERIC | Sum of valid completed item sale prices |
| `average_order_value` | NUMERIC | Average completed-order value |
| `purchased_items` | INTEGER | Count of completed order items |

## `customer_segments`

Extends `customer_rfm_metrics` with relative scores and a segment.

| Field | Type | Definition |
|---|---|---|
| `r_score` | INTEGER | Recency quintile, 5 = most recent |
| `f_score` | INTEGER | Frequency quintile, 5 = most frequent |
| `m_score` | INTEGER | Monetary quintile, 5 = highest spend |
| `rfm_code` | STRING | Concatenated R, F, and M scores |
| `rfm_average` | FLOAT | Mean of the three scores |
| `segment` | STRING | Ordered, mutually exclusive business segment |

## Grain and reconciliation

The transformation moves through three explicit grains:

1. One row per order item after deduplication
2. One row per customer and order in `order_totals`
3. One row per customer in the RFM outputs

This prevents a multi-item order from being counted as multiple orders. The
validation suite confirms that customer row counts and monetary totals do not
change during scoring and segmentation.

