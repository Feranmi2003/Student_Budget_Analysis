# Student Budget Analysis

### SQL + Excel End-to-End Data Analysis Project



##### Project Overview

This project analyzes the spending habits, income gaps, and financial behaviour of **1,000 university students** across 4 year groups, 5 majors, and ages 18–25.

The goal was to simulate a real-world analyst workflow:

* Use **MySQL** to query, aggregate, and extract insights from raw data
* Use **Excel** to visualize findings in a clean, portfolio-ready dashboard

\---

## Dataset

|Field|Detail|
|-|-|
|Records|1,000 students|
|Age range|18–25|
|Year groups|Freshman, Sophomore, Junior, Senior|
|Majors|Engineering, Biology, Economics, Computer Science, Psychology|
|Payment methods|Cash, Credit/Debit Card, Mobile Payment App|
|Spending categories|Tuition, Housing, Food, Transportation, Books \& Supplies, Entertainment, Personal Care, Technology, Health \& Wellness, Miscellaneous|
|Income fields|Monthly Income, Financial Aid|

> Raw CSV file included in this repository. Data cleaning was performed in Excel prior to SQL import.

\---

## Tools Used

* **MySQL Workbench** — database setup, querying, and data extraction
* **Microsoft Excel** — data visualization, pivot tables, conditional formatting, dashboard design
* **GitHub** — version control and project sharing

\---

## Project Workflow

```
Raw CSV
   ↓
Excel (data cleaning)
   ↓
MySQL Workbench (CREATE DATABASE → CREATE TABLE → Import CSV)
   ↓
5 SQL Queries (aggregation, subquery, window function)
   ↓
Export results as CSV
   ↓
Excel Dashboard (5 charts + summary dashboard sheet)
```

\---

## SQL Queries

### Query 1 — Average Spending by Year in School

**Business question:** Which year group spends the most, and on what category?

```sql
SELECT
  Year\\\_in\\\_school,
  ROUND(AVG(Food), 2)          AS Avg\\\_Food,
  ROUND(AVG(Housing), 2)       AS Avg\\\_Housing,
  ROUND(AVG(Entertainment), 2) AS Avg\\\_Entertainment,
  ROUND(AVG(Transportation), 2) AS Avg\\\_Transportation,
  ROUND(AVG(
    Tuition + Housing + Food + Transportation +
    Books\\\_supplies + Entertainment + Personal\\\_care +
    Technology + Health\\\_wellness + Miscellaneous
  ), 2) AS Avg\\\_Calculated\\\_Total
FROM student\\\_budget
GROUP BY Year\\\_in\\\_school
ORDER BY Avg\\\_Calculated\\\_Total DESC;
```

\---

### Query 2 — Income vs Expense Gap (Surplus or Deficit)

**Business question:** Are students covering their total costs with income and financial aid?

```sql
SELECT
  Year\\\_in\\\_school,
  Gender,
  ROUND(AVG(Monthly\\\_income), 2) AS Avg\\\_Income,
  ROUND(AVG(Financial\\\_aid), 2)  AS Avg\\\_Aid,
  ROUND(AVG(
    Tuition + Housing + Food + Transportation +
    Books\\\_supplies + Entertainment + Personal\\\_care +
    Technology + Health\\\_wellness + Miscellaneous
  ), 2) AS Avg\\\_Spending,
  ROUND(AVG(
    Monthly\\\_income + Financial\\\_aid -
    (Tuition + Housing + Food + Transportation +
     Books\\\_supplies + Entertainment + Personal\\\_care +
     Technology + Health\\\_wellness + Miscellaneous)
  ), 2) AS Avg\\\_Surplus\\\_Deficit
FROM student\\\_budget
GROUP BY Year\\\_in\\\_school, Gender
ORDER BY Avg\\\_Surplus\\\_Deficit ASC;
```

\---

### Query 3 — Spending Breakdown by Major

**Business question:** Does your field of study affect how you spend money?

```sql
SELECT
  Major,
  ROUND(AVG(Tuition), 2)        AS Avg\\\_Tuition,
  ROUND(AVG(Housing), 2)        AS Avg\\\_Housing,
  ROUND(AVG(Food), 2)           AS Avg\\\_Food,
  ROUND(AVG(Technology), 2)     AS Avg\\\_Technology,
  ROUND(AVG(Books\\\_supplies), 2) AS Avg\\\_Books,
  ROUND(AVG(
    Tuition + Housing + Food + Transportation +
    Books\\\_supplies + Entertainment + Personal\\\_care +
    Technology + Health\\\_wellness + Miscellaneous
  ), 2) AS Avg\\\_Calculated\\\_Total,
  COUNT(\\\*) AS Student\\\_Count
FROM student\\\_budget
GROUP BY Major
ORDER BY Avg\\\_Calculated\\\_Total DESC;
```

\---

### Query 4 — Top Overspenders (Subquery + JOIN)

**Business question:** Which students spend 30%+ above their year group's average?

```sql
SELECT
  s.Age,
  s.Gender,
  s.Year\\\_in\\\_school,
  s.Major,
  (s.Tuition + s.Housing + s.Food + s.Transportation +
   s.Books\\\_supplies + s.Entertainment + s.Personal\\\_care +
   s.Technology + s.Health\\\_wellness + s.Miscellaneous) AS Their\\\_Total,
  ROUND(avg\\\_by\\\_year.Avg\\\_Spending, 2)                   AS Year\\\_Avg\\\_Spending,
  ROUND((s.Tuition + s.Housing + s.Food + s.Transportation +
   s.Books\\\_supplies + s.Entertainment + s.Personal\\\_care +
   s.Technology + s.Health\\\_wellness + s.Miscellaneous)
   - avg\\\_by\\\_year.Avg\\\_Spending, 2)                      AS Overspend\\\_Amount
FROM student\\\_budget s
JOIN (
  SELECT
    Year\\\_in\\\_school,
    AVG(Tuition + Housing + Food + Transportation +
        Books\\\_supplies + Entertainment + Personal\\\_care +
        Technology + Health\\\_wellness + Miscellaneous) AS Avg\\\_Spending
  FROM student\\\_budget
  GROUP BY Year\\\_in\\\_school
) avg\\\_by\\\_year
  ON s.Year\\\_in\\\_school = avg\\\_by\\\_year.Year\\\_in\\\_school
WHERE
  (s.Tuition + s.Housing + s.Food + s.Transportation +
   s.Books\\\_supplies + s.Entertainment + s.Personal\\\_care +
   s.Technology + s.Health\\\_wellness + s.Miscellaneous)
   > avg\\\_by\\\_year.Avg\\\_Spending \\\* 1.15
ORDER BY Overspend\\\_Amount DESC
LIMIT 50;
```

\---

### Query 5 — Payment Method by Age Group (Window Function)

**Business question:** Do payment method preferences shift as students get older?

```sql
SELECT
  Age,
  Preferred\\\_payment\\\_method,
  COUNT(\\\*) AS Student\\\_Count,
  ROUND(
    COUNT(\\\*) \\\* 100.0 / SUM(COUNT(\\\*))
      OVER (PARTITION BY Age),
  1) AS Pct\\\_Within\\\_Age
FROM student\\\_budget
GROUP BY Age, Preferred\\\_payment\\\_method
ORDER BY Age, Student\\\_Count DESC;
```

> Requires MySQL 8.0+ for the window function (`OVER PARTITION BY`).

\---

## Key Findings

|#|Finding|
|-|-|
|1|**Housing is the largest variable cost** across all year groups, with Freshman and Senior students showing the highest average spending|
|2|**All 12 year-gender combinations run a deficit** — monthly income and financial aid do not fully cover student spending across any group|
|3|**Tuition dominates spending across all majors**, accounting for the largest share of total budget regardless of field of study|
|4|**Senior - Engineering** is the top overspending profile, exceeding their year group average by \~$1,993|
|5|**Payment method preferences are stable across ages 18–25**, with Credit/Debit Card being the dominant method overall and Mobile Payment Apps peaking at 44% among 20-year-olds|

\---

## Excel Dashboard

The final dashboard contains 5 charts built from the SQL query exports:

|Sheet|Chart Type|Description|
|-|-|-|
|Q1 Year Spending|Clustered Bar|Average spending by category and year group|
|Q2 Income Gap|Clustered Bar (negative axis)|Surplus or deficit by year and gender|
|Q3 By Major|Stacked Bar|Spending composition broken down by major|
|Q4 Over spenders|Horizontal Bar|Top 20 over spenders vs year group average|
|Q5 Payment Method|100% Stacked Bar|Payment method share by age group|
|**Dashboard**|Summary|All 5 charts + insight sentences in one view|

\---

## Repository Structure

```
student-budget-analysis/
│
├── data/
│   └── student\\\_budget\\\_raw.csv          # Raw dataset (1,000 records)
│
├── sql/
│   └── queries.sql                     # All 5 MySQL queries
│
├── excel/
│   └── Student\\\_Budget\\\_Analysis.xlsx    # Dashboard + all chart sheets
│
├── exports/
│   ├── q1\\\_spending\\\_by\\\_year.csv
│   ├── q2\\\_income\\\_vs\\\_expense.csv
│   ├── q3\\\_spending\\\_by\\\_major.csv
│   ├── q4\\\_overspenders.csv
│   └── q5\\\_payment\\\_by\\\_age.csv
│
└── README.md
```

\---

## How to Reproduce This Project

1. Download the raw CSV from the `data/` folder
2. Open **MySQL Workbench** and run the setup commands:

```sql
   CREATE DATABASE student\\\_project;
   USE student\\\_project;
   ```

3. Create the table using the schema in `queries.sql`
4. Import the CSV using the Table Data Import Wizard
5. Run each query in `queries.sql` and export results as CSV
6. Open `Student\\\_Budget\\\_Analysis.xlsx` to view the dashboard

\---

## About

**Oluwaferanmi Otudeko Michael**  
Third-year Honours Information Technology student · York University · Toronto, ON, Canada  
[LinkedIn](https://www.linkedin.com/in/oluwaferanmi-otudeko)

\---

*Built as a self-directed portfolio project to demonstrate end-to-end data analysis using SQL and Excel.*

