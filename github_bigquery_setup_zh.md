# 从本地文件到 GitHub 和 BigQuery

先记住两个平台的分工：

- **GitHub**：公开保存和展示项目代码，简历放这个链接；
- **BigQuery**：实际运行 SQL、生成表和查询结果，一般不公开账号页面。

两者不必连接也能完成项目。对于第一次做项目，推荐先上传 GitHub，再从 GitHub 逐个复制 SQL 到 BigQuery。这样最简单，也最不容易被权限问题卡住。

## 第一步：下载并解压项目

1. 下载 `rfm-customer-segmentation.zip`。
2. 在 Windows 中右键 ZIP，选择“全部解压”。
3. 解压后应该看到：

```text
rfm-customer-segmentation
|-- README.md
|-- docs
`-- sql
```

如果只能看到 ZIP，说明还没有解压；GitHub 不会自动替你解压 ZIP。

## 第二步：创建 GitHub 仓库

1. 登录 GitHub，然后打开 <https://github.com/new>。
2. Repository name 填：`rfm-customer-segmentation`。
3. Description 可填：

   `Customer segmentation with BigQuery SQL, RFM scoring, data validation, and Power BI-ready views.`

4. 选择 **Public**，这样简历查看者可以打开。
5. 不要勾选 Add a README、Add .gitignore 或 Choose a license，因为项目里已经有 README 和 .gitignore。
6. 点击 **Create repository**。

## 第三步：通过网页上传项目

1. 在新仓库页面点击 **Add file > Upload files**。如果仓库是空的，也可以点击 `uploading an existing file`。
2. 打开刚才解压的文件夹。
3. 把文件夹里面的 `README.md`、`docs`、`sql` 和 `.gitignore` 拖进 GitHub 上传区域。不要只上传 ZIP。
4. Commit message 填：`Add BigQuery RFM customer segmentation project`。
5. 点击 **Commit changes**。
6. 回到仓库首页，确认能看到 README，以及 `sql`、`docs` 两个文件夹。
7. 复制仓库网址。格式通常是：

   `https://github.com/你的用户名/rfm-customer-segmentation`

这个网址就是以后放进简历项目标题的 GitHub 链接。

## 第四步：准备 BigQuery

1. 打开 <https://console.cloud.google.com/bigquery>。
2. 登录 Google 账号。
3. 页面顶部选择一个 Google Cloud Project；如果没有，先创建一个，例如 `grace-sql-portfolio`。
4. 记下 **Project ID**。注意它不一定和项目显示名称完全一样。
5. 如果页面要求启用 BigQuery API，点击 Enable。
6. 如果要求设置 Billing，请按页面提示操作。公共数据的存储由 Google 提供，但查询计算使用你的 Cloud Project。
7. BigQuery 页面右上或中间点击 **SQL query / Compose new query**。

## 第五步：先做最小测试

把下面的查询粘贴到 BigQuery SQL 编辑器：

```sql
SELECT
  status,
  COUNT(*) AS item_rows
FROM `bigquery-public-data.thelook_ecommerce.order_items`
GROUP BY status
ORDER BY item_rows DESC;
```

点击 **Run**。如果结果出现 `Complete`、`Shipped`、`Processing`、`Cancelled`、`Returned` 等状态，说明公共数据可以正常访问。

## 第六步：运行项目 SQL

在 GitHub 仓库中打开 `sql` 文件夹，严格按编号运行：

1. `00_setup.sql`
2. `01_profile_source.sql`
3. `02_build_customer_rfm.sql`
4. `03_score_and_segment.sql`
5. `04_validate.sql`
6. `05_analyze_segments.sql`
7. `06_power_bi_views.sql`

对每个文件执行同样的操作：

1. 在 GitHub 打开 SQL 文件；
2. 点击复制代码按钮，或全选代码后复制；
3. 回到 BigQuery，点击新的 SQL query 标签；
4. 粘贴代码；
5. 把所有 `your-gcp-project` 替换成第四步记下的 Project ID；
6. 确认 Query settings 的 Data location 是 `US`；
7. 点击 Run；
8. 成功后再运行下一个文件。

例如，Project ID 是 `grace-sql-portfolio-123`，那么：

```sql
`your-gcp-project.rfm_customer_segmentation.customer_segments`
```

应改成：

```sql
`grace-sql-portfolio-123.rfm_customer_segmentation.customer_segments`
```

## 第七步：检查是否成功

运行 `04_validate.sql` 后，结果应该出现八行，而且 `status` 全部为 `PASS`。在左侧 Explorer 中展开：

```text
你的 Project ID
`-- rfm_customer_segmentation
    |-- customer_rfm_metrics
    |-- customer_segments
    |-- data_quality_checks
    |-- stg_order_items_snapshot
    |-- v_customer_rfm
    |-- v_monthly_sales_by_segment
    `-- v_segment_summary
```

保留 8/8 PASS 的截图。然后运行 `05_analyze_segments.sql`，把真实客户数、订单数、收入和最高收入 Segment 填回 README。不要在运行前填写或猜测数字。

## 可选：把 BigQuery Studio 直接连接到 GitHub

Google 当前提供 BigQuery Studio Git repository 功能，但它仍是 Preview，而且可能需要 Developer Connect 权限。初学阶段完全可以跳过。

如果你的 BigQuery 页面能够看到该功能：

1. 左侧点击 **Files**；
2. 在你的 user root 旁点击三点菜单；
3. 选择 **Create > Git repository**；
4. 粘贴 GitHub 仓库网址；
5. 按提示创建 Developer Connect account connector，或选择 HTTPS 连接；
6. 连接后，在文件树里打开 `.sql` 文件编辑和运行。

如果没有这个入口，继续使用“GitHub 复制代码 → BigQuery 运行”的方式即可，不影响项目质量。

## 简历应该链接哪里

简历项目标题链接到 GitHub 仓库，例如：

```text
RFM Customer Segmentation Analysis | BigQuery SQL, Power BI | GitHub
```

其中 `GitHub` 链接到公开仓库。不要链接自己的 Google Cloud Console，因为其他人通常没有访问权限。

