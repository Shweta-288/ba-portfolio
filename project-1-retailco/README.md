# Project 1 — RetailCo Customer Analytics

**Domain:** Retail / E-Commerce | **Duration:** 12 weeks | **Status:** Complete

**Tools:** SQL · Power BI · Excel · draw.io · Confluence · Jira

---

## The Problem

RetailCo UK had a 30% customer churn rate. In the Bronze loyalty tier it was closer to 80%. The marketing team knew something was wrong but couldn't identify which customers were at risk or when to intervene. Their weekly retention report took 3 to 4 hours of manual Excel work every Monday and still didn't answer the right questions.

## What I Did

I came in as the sole BA and owned the full requirements lifecycle — from the first discovery workshop to final sign-off.

I facilitated a workshop with the CCO, Marketing Director, and Head of Analytics. That surfaced a tension early: the CCO wanted a predictive AI model, the Marketing Director needed a working dashboard in eight weeks. Those weren't compatible in a single delivery, so I ran a MoSCoW prioritisation session, proposed a phased approach, and got both stakeholders signed off.

From there I did 1-to-1 interviews with the Customer Success Manager (who turned out to be the most useful person on the project — she was spending four hours every Monday doing what a dashboard should do automatically), mapped the current process in draw.io, ran SQL analysis on the actual dataset, wrote the full BRD, and defined the Power BI dashboard requirements.

## SQL Analysis — Key Findings

Five modules run across customers, orders, and products datasets.

| Metric | Finding |
|---|---|
| Overall churn rate | 30% |
| Bronze tier churn | ~80% |
| Platinum / Gold tier churn | 0–5% |
| Avg days since last order (churned customers) | 650+ days |
| Top revenue category | Electronics |
| Active customers with "At Risk" RFM score | 4 customers needing immediate outreach |

The RFM segmentation model split active customers into five groups: Champions, Loyal Customers, Potential Loyalists, At Risk, and Lost. The SQL file in this folder contains all five analysis modules with comments explaining each query.

## Files in This Folder

| File | What it is |
|---|---|
| `RetailCo_BRD_v1.0.docx` | Full Business Requirements Document — 10 sections, 18 requirements, 5 user stories, stakeholder register, risk register |
| `retailco_sql_analysis.sql` | SQL analysis across 5 modules — run in sqliteonline.com with the CSV files |
| `retailco_customers.csv` | 50 UK customers with loyalty tier, churn flag, spend, and days since last order |
| `retailco_orders.csv` | 50 orders across 5 product categories |
| `retailco_products.csv` | 50 products with ratings, stock levels, and supplier data |

## Full Case Study

Full write-up with process maps, elicitation approach, challenges, and outcomes is on the Notion portfolio:
[View on Notion →](https://rattle-dogwood-96b.notion.site/Portfolio-Shweta-Goyal-Technical-BA-3679d574c24c80369bb2e15ae5a862a6)
