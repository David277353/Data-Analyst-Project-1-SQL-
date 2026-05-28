# 🛒 E-Commerce Data Analytics — Google Analytics Sample Dataset

SQL and BigQuery analysis of Google Analytics session data to uncover revenue trends, user behavior, and product insights across a real-world e-commerce dataset.

---

## 🧩 The Business Problem

Raw Google Analytics data contains millions of rows of session, traffic, and transaction data — but on its own it doesn't answer the questions that actually drive decisions:

- **Which traffic sources are generating revenue, not just visits?**
- **Are users who bounce costing us more than users who convert?**
- **What products do customers buy together — and how can we use that to bundle smarter?**

This project works through those questions systematically using BigQuery SQL on Google's public GA360 dataset.

---

## 🛠 Technologies Used

| Tool | Purpose |
|---|---|
| **Google BigQuery** | Cloud SQL database and query engine |
| **SQL (BigQuery dialect)** | All analysis and data transformation |
| **Dataset** | `bigquery-public-data.google_analytics_sample` |

> 💡 No setup or data loading needed — the dataset is publicly available in BigQuery. See **How to Run** below.

---

## 📊 Analysis Covered

| # | Business Question | SQL Technique |
|---|---|---|
| Q1 | Total visits, pageviews & transactions (Jan–Mar 2017) | Aggregation, DATE parsing |
| Q2 | Bounce rate by traffic source (Jul 2017) | Aggregation, ratio calculation |
| Q3 | Revenue by traffic source — weekly & monthly (Jun 2017) | CTE, UNION ALL |
| Q4 | Conversion rate by traffic source (2017) | Aggregation, HAVING |
| Q5 | Avg pageviews: purchasers vs non-purchasers (Jun–Jul 2017) | CTE, FULL JOIN |
| Q6 | Avg transactions per user (Jul 2017) | Aggregation |
| Q7 | Revenue contribution by device category (2017) | Window Function, ratio |
| Q8 | Co-purchase analysis — "YouTube Men's Vintage Henley" (Jul 2017) | CTE, JOIN, UNNEST |
| Q10 | Weekly revenue & cumulative revenue (May–Jul 2017) | Window Function, SUM OVER |

---

## ✨ Key Technical Highlights

**Cumulative Revenue Tracking**
Used `SUM() OVER (ORDER BY week)` window functions to track business pacing over time — showing not just weekly revenue but how the business was trending toward its period target.

**Co-Purchase / Product Affinity Analysis**
Identified which products are most frequently bought alongside the "YouTube Men's Vintage Henley" — directly actionable for product bundling and cross-sell campaign strategy.

**UNNEST on Nested Arrays**
The GA360 schema stores hits and product data as repeated nested fields. Used `UNNEST()` to flatten these into queryable rows — a technique essential for working with real-world event-based datasets.

**Multiple Approaches Per Query**
Each query includes alternative implementations (CTE vs subquery vs window function) with inline notes on trade-offs — demonstrating not just what works, but *why* one approach is preferred over another.

---

## 💡 Key Findings

- Traffic sources varied significantly in conversion rate — high-visit sources did not always correlate with high revenue, suggesting budget reallocation opportunities
- Purchasers averaged significantly more pageviews than non-purchasers — indicating engagement depth as a leading indicator of conversion
- Co-purchase analysis revealed clear product affinity patterns that could inform bundling and upsell strategies
- Cumulative revenue tracking showed uneven weekly pacing — useful for forecasting and identifying promotional timing opportunities

---

## ✅ Business Recommendations

1. **Reallocate marketing spend** toward traffic sources with the highest conversion rate, not just highest visit volume
2. **Use pageview depth as a retargeting signal** — users who browse extensively but don't convert are high-value remarketing targets
3. **Build product bundles** around the co-purchase pairs identified in Q8 — these have proven purchase affinity
4. **Monitor cumulative revenue weekly** against period targets to catch pacing issues early enough to act

---

## 🚀 How to Run

1. Go to [Google BigQuery Console](https://console.cloud.google.com/bigquery)
2. Ensure you have access to `bigquery-public-data.google_analytics_sample`
3. Open a new query editor tab
4. Paste any query from `DAC_K45_-_Khoa_Tran.sql`
5. Run — no data loading or setup required

---

## 📁 File Structure

```
ecommerce-analytics-bigquery/
├── DAC_K45_-_Khoa_Tran.sql   # All queries with explanations and alternative approaches
└── README.md
```

> 💡 **Tip:** Rename the .sql file to `ecommerce-analysis-queries.sql` before uploading — it reads more professionally than a course submission filename.

---

## 🗓 Timeline

January 2026 – February 2026

---

## 👤 Author

**Khoa (David) Tran**
Data Analyst | SQL · BigQuery · Power BI · Python · Tableau
[LinkedIn](https://www.linkedin.com/in/khoatran-da) · [GitHub](https://github.com/David277353)

---

*Feedback welcome — feel free to open an issue or reach out directly.*
