# 🚀 Digital Marketing & E-Commerce Data Analysis Project

This project demonstrates **advanced data analysis skills** using a real-world e-commerce dataset. The goal is to optimize marketing spend across platforms and analyze user behavior through the conversion funnel.

## 🎯 Project Objective
To analyze the performance of online marketing campaigns (Facebook & Google Ads) and measure user journey efficiency on the e-commerce platform using **Google Analytics 4 (GA4)** data.

---

## 📂 Part 1: Marketing Campaign Analysis (PostgreSQL)
In this section, I joined and analyzed `facebook_ads` and `google_ads` datasets to calculate key performance metrics like **ROMI (Return on Marketing Investment)** and **CPC (Cost Per Click)**.

**Key Insights & Tasks:**
* Calculated daily average, min, and max spend for each platform.
* Identified top performing days based on **Total ROMI**.
* Analyzed campaign longevity to find the longest-running ad sets.

**🛠 Tech Stack:**
* **SQL Dialect:** PostgreSQL
* **Skills:** Common Table Expressions (CTEs), Window Functions, Aggregations.
* **Code:** [View SQL Scripts](./SQL_Analysis_PostgreSQL)

---

## 📊 Part 2: GA4 Conversion Funnel Analysis (BigQuery)
Using raw event-based data from Google Analytics 4, I constructed a conversion funnel to track user drop-offs from session start to purchase.

**Key Tasks:**

### 1. Data Preparation & Cleaning (ETL)
Filtered and transformed raw event data for the year 2021.
* **Goal:** Extract clean fields like `user_pseudo_id`, `session_id`, and corrected `event_timestamp`.
* 🔗 [View Query in BigQuery](https://github.com/oguzhanuzunlu/Digital-Marketing-Ecommerce-Analysis/blob/main/BigQuery_GA4_Analysis/1_ga4_data_cleaning_etl.sql)

### 2. Traffic Source Analysis
Calculated conversion rates broken down by `source`, `medium`, and `campaign`.
* **Logic:** Aggregated distinct sessions that triggered `view_item`, `add_to_cart`, and `purchase`.
* 🔗 [View Query in BigQuery](https://github.com/oguzhanuzunlu/Digital-Marketing-Ecommerce-Analysis/blob/main/BigQuery_GA4_Analysis/2_traffic_source_conversion_funnel.sql)

### 3. Landing Page Performance
Analyzed which landing pages (`page_path`) drove the highest number of purchases in 2020.
* **Logic:** Mapped session start pages to final purchase events using `user_id` + `session_id`.
* 🔗 [View Query in BigQuery](https://github.com/oguzhanuzunlu/Digital-Marketing-Ecommerce-Analysis/blob/main/BigQuery_GA4_Analysis/3_landing_page_performance.sql)

**🛠 Tech Stack:**
* **Platform:** Google BigQuery
* **Skills:** Standard SQL, UNNEST (handling nested arrays), Date Functions, Advanced Joins.

---

## 📈 Tools Used
* **Database:** PostgreSQL (DBeaver), Google BigQuery
* **Visualization:** (Optional: Google Looker Studio)
* **Language:** SQL
