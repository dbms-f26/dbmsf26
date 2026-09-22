SELECT * FROM COUNTRY;			-- SQL is not case-sensitive.
SELECT Code, Name FROM Country;
SELECT Code, Name FROM Country ORDER BY Name;
SELECT Code, Name FROM Country ORDER BY Population DESC;

-- Multiple queries in the same .sql file should be separated by semicolons.
-- Is how you specify a comment.

-- What is the life expectancy in USA?
SELECT Life_Expectancy FROM Country WHERE CODE = 'USA';
-- Select all countries with life expectancy > 80 years.
SELECT * FROM Country WHERE Life_Expectancy > 80;
-- How many countries have life expectancy > 80 years?
SELECT COUNT(*) FROM Country WHERE Life_Expectancy > 80;
-- Use an alias:
SELECT Name, GNP/Population AS GNP_Per_Capita FROM Country WHERE Life_Expectancy>80;
-- Use a summary statistic (average or mean) (SQL also supports MIN, MAX, SUM…) 
SELECT AVG(GNP/Population) FROM Country WHERE Life_Expectancy>80;
SELECT AVG(GNP/Population) FROM Country WHERE Life_Expectancy<60;

-- Get a list of countries with "republic" in the name
SELECT * FROM country WHERE Name LIKE '%Republic%';
-- Get a list of countries whose name starts with ”Mac”
SELECT * FROM country WHERE Name LIKE 'Mac%';
-- LIKE is not case-sensitive

