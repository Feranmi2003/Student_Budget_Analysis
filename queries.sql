CREATE DATABASE student_project;
USE student_project;

CREATE TABLE student_budget (
  Ind              INT,
  Age              INT,
  Gender           VARCHAR(20),
  Year_in_school   VARCHAR(20),
  Major            VARCHAR(50),
  Monthly_income   INT,
  Financial_aid    INT,
  Tuition          INT,
  Housing          INT,
  Food             INT,
  Transportation   INT,
  Books_supplies   INT,
  Entertainment    INT,
  Personal_care    INT,
  Technology       INT,
  Health_wellness  INT,
  Miscellaneous    INT,
  Preferred_payment_method VARCHAR(30)
);



SELECT COUNT(*) FROM student_budget;

SELECT
Year_in_school,
ROUND(AVG(Food), 2)                        AS Avg_Food,
ROUND(AVG(Housing), 2)                     AS Avg_Housing,
ROUND(AVG(Entertainment), 2)               AS Avg_Entertainment,
ROUND(AVG(Transportation), 2)              AS Avg_Transportation,
ROUND(AVG(
    Tuition + Housing + Food + Transportation +
    Books_supplies + Entertainment + Personal_care +
    Technology + Health_wellness + Miscellaneous
  ), 2)                                        AS Avg_Calculated_Total
FROM student_budget
GROUP BY Year_in_school
ORDER BY Avg_Calculated_Total DESC;




SELECT
Year_in_school,
Gender,
ROUND(AVG(Monthly_income), 2)              AS Avg_Income,
ROUND(AVG(Financial_aid), 2)               AS Avg_Aid,
ROUND(AVG(
    Tuition + Housing + Food + Transportation +
    Books_supplies + Entertainment + Personal_care +
    Technology + Health_wellness + Miscellaneous
  ), 2)                                        AS Avg_Spending,
ROUND(AVG(
    Monthly_income + Financial_aid -
    (Tuition + Housing + Food + Transportation +
     Books_supplies + Entertainment + Personal_care +
     Technology + Health_wellness + Miscellaneous)
  ), 2)                                        AS Avg_Surplus_Deficit
FROM student_budget
GROUP BY Year_in_school, Gender
ORDER BY Avg_Surplus_Deficit ASC;



SELECT
Major,
ROUND(AVG(Tuition), 2)           AS Avg_Tuition,
ROUND(AVG(Housing), 2)           AS Avg_Housing,
ROUND(AVG(Food), 2)              AS Avg_Food,
ROUND(AVG(Technology), 2)        AS Avg_Technology,
ROUND(AVG(Books_supplies), 2)    AS Avg_Books,
ROUND(AVG(
    Tuition + Housing + Food + Transportation +
    Books_supplies + Entertainment + Personal_care +
    Technology + Health_wellness + Miscellaneous
  ), 2)                              AS Avg_Calculated_Total,
  COUNT(*)                          AS Student_Count
FROM student_budget
GROUP BY Major
ORDER BY Avg_Calculated_Total DESC;



SELECT
s.Age,
s.Gender,
s.Year_in_school,
s.Major,
(s.Tuition + s.Housing + s.Food + s.Transportation +
s.Books_supplies + s.Entertainment + s.Personal_care +
s.Technology + s.Health_wellness + s.Miscellaneous)   AS Their_Total,
ROUND(avg_by_year.Avg_Spending, 2)                   AS Year_Avg_Spending,
ROUND((s.Tuition + s.Housing + s.Food + s.Transportation +
   s.Books_supplies + s.Entertainment + s.Personal_care +
   s.Technology + s.Health_wellness + s.Miscellaneous)
   - avg_by_year.Avg_Spending, 2)                        AS Overspend_Amount
FROM student_budget s
JOIN (
  SELECT
    Year_in_school,
	AVG(Tuition + Housing + Food + Transportation +
        Books_supplies + Entertainment + Personal_care +
        Technology + Health_wellness + Miscellaneous)    AS Avg_Spending
  FROM student_budget
  GROUP BY Year_in_school
) avg_by_year
  ON s.Year_in_school = avg_by_year.Year_in_school
WHERE
  (s.Tuition + s.Housing + s.Food + s.Transportation +
   s.Books_supplies + s.Entertainment + s.Personal_care +
   s.Technology + s.Health_wellness + s.Miscellaneous)
   > avg_by_year.Avg_Spending * 1.15
ORDER BY Overspend_Amount DESC
LIMIT 50;




SELECT
Age,
Preferred_payment_method,
COUNT(*)                                           AS Student_Count,
ROUND(
    COUNT(*) * 100.0 / SUM(COUNT(*))
      OVER (PARTITION BY Age),
  1)                                                 AS Pct_Within_Age
FROM student_budget
GROUP BY Age, Preferred_payment_method
ORDER BY Age, Student_Count DESC;
