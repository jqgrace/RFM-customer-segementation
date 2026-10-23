# 中文实操路线

这套项目不是“复制代码后立刻写进简历”，而是按证据逐层升级。每完成一阶段，保留结果截图或导出表，再更新 README 和简历。

## 阶段 1：认识数据

运行 `sql/01_profile_source.sql`，回答四个问题：

1. `status` 有哪些值？
2. 数据覆盖什么日期？
3. 截止日期之前有多少用户、订单、明细行？
4. ID、价格和时间字段有多少无效值？

在 README 的 Results 区域记录结果。此时可以解释为什么只把 `Complete` 计入实际消费。

## 阶段 2：清洗和控制粒度

运行 `sql/02_build_customer_rfm.sql`。重点理解：

- `parameters`：把分析日期集中管理；
- `source_items`：只选择会用到的字段；
- `deduplicated_items`：用 `ROW_NUMBER()` 保留唯一明细；
- `valid_items`：排除空键、非正价格和未完成订单；
- `order_totals`：先变成“一行一个订单”；
- `customer_metrics`：再变成“一行一个客户”。

请能用自己的话说明：为什么 Frequency 不能直接 `COUNT(*)`。答案是：一笔订单可能包含多条商品明细，直接数行会把多商品订单重复计算。

## 阶段 3：窗口函数评分

运行 `sql/03_score_and_segment.sql`。`NTILE(5)` 把用户按相对表现分成五组。Recency 越小越好，所以 R 分数要反向；Frequency 和 Monetary 越大越好，所以直接按升序分位。

思考并记录：相同 Frequency 的用户可能被分进相邻分位，这是 `NTILE` 为了保持每组人数接近而产生的行为。这个项目用 `user_id` 做稳定的次级排序，从而让结果可重复。

## 阶段 4：CASE 分群

同一个用户可能满足多条业务规则，因此 `CASE` 的顺序就是优先级。例如“Champions”必须放在“Loyal Customers”之前，否则冠军用户会先被较宽的忠诚规则截走。

抽查每个 Segment 的几条记录，确认 R、F、M 与命名直觉一致。

## 阶段 5：质量校验

运行 `sql/04_validate.sql`，八项检查都应为 `PASS`。至少保存以下证据：

- 查询结果截图；
- 运行时间；
- 8/8 checks passed；
- 用户数和 Monetary 总额在评分前后完全对齐。

如果任何一项失败，先修 SQL，不要继续做仪表盘，也不要把结果写进简历。

## 阶段 6：分析业务含义

运行 `sql/05_analyze_segments.sql`，回答：

- 哪个 Segment 用户最多？
- 哪个 Segment 贡献收入最多？
- 哪个 Segment 的客单价最高？
- At Risk 和 Can't Lose Them 中，哪些匿名客户最值得优先召回？

不要声称这些动作已经提升留存或收入，除非你真的有实验或上线后的数据。

## 阶段 7：Power BI

运行 `sql/06_power_bi_views.sql`，然后按 `docs/power_bi.md` 建报表。完成后把截图放在 `images/`，并在 README 展示 1–2 张最清晰的图。

## 阶段 8：简历与面试

使用 `docs/resume_bullets.md` 中与你真实完成阶段相匹配的版本。面试前应能在 90 秒内讲清楚：

1. 业务问题；
2. 数据粒度和清洗规则；
3. RFM 特征如何构造；
4. 为什么使用窗口函数和 CASE；
5. 怎样验证结果；
6. 一个主要发现和一个局限。

