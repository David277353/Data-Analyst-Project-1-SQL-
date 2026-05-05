# E-Commerce Data Analytics — Google Analytics Sample Dataset

SQL and BigQuery analysis of Google Analytics session data to uncover revenue trends,
user behavior, and product insights.

## 📋 Description

This project analyzes Google's public GA360 e-commerce dataset using BigQuery SQL.
It covers traffic performance, revenue attribution, user purchase behavior, and
product affinity — providing actionable insights for marketing and sales strategy.

## 🛠️ Technologies Used

- **Database:** Google BigQuery
- **Dataset:** `bigquery-public-data.google_analytics_sample`
- **Language:** SQL (BigQuery dialect)

## 📁 File Structure

ecommerce-analytics-bigquery/
├── DAC_K45_-_Khoa_Tran.sql      # All queries with explanations and alternative approaches
└── README.md

## 🚀 How to Run

1. Go to [Google BigQuery Console](https://console.cloud.google.com/bigquery)
2. Make sure you have access to `bigquery-public-data.google_analytics_sample`
3. Open a new query editor and paste any query from the `.sql` file
4. Run the query — no setup or data loading needed

## 📊 Analysis Covered

| # | Question | Technique |
|---|----------|-----------|
| Q1 | Total visits, pageviews & transactions (Jan–Mar 2017) | Aggregation, DATE parsing |
| Q2 | Bounce rate by traffic source (Jul 2017) | Aggregation, ratio calculation |
| Q3 | Revenue by traffic source — weekly & monthly (Jun 2017) | CTE, UNION ALL |
| Q4 | Conversion rate by traffic source (2017) | Aggregation, HAVING |
| Q5 | Avg pageviews: purchasers vs non-purchasers (Jun–Jul 2017) | CTE, FULL JOIN |
| Q6 | Avg transactions per user (Jul 2017) | Aggregation |
| Q7 | Revenue contribution by device category (2017) | Window Function, ratio |
| Q8 | Co-purchase analysis — "YouTube Men's Vintage Henley" (Jul 2017) | CTE, JOIN, UNNEST |
| Q10 | Weekly revenue & cumulative revenue (May–Jul 2017) | Window Function, SUM OVER |

## ✨ Key Features

- **Cumulative Revenue Tracking** using `SUM() OVER (ORDER BY week)` Window Functions
  to monitor business pacing over time
- **Co-purchase / Product Affinity Analysis** to identify cross-selling opportunities
  for product bundling strategies
- **UNNEST operations** on nested `hits` and `product` arrays within the BigQuery
  GA schema to handle complex repeated fields
- **Multiple approaches** shown per query (CTE, subquery, window functions)
  with inline notes on trade-offs and best practices

## 🗓️ Timeline

**January 2026 – February 2026**

## 👤 Author

**Khoa Tran** 