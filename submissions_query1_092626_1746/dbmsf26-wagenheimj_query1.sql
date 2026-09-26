-- HW1 Submission
SET search_path TO world;

SELECT Population FROM Country WHERE name = 'United States';
SELECT Code FROM Country WHERE name = 'India';
SELECT Language FROM CountryLanguage where country_code = 'IND' ORDER BY LANGUAGE;
SELECT Language, Percentage FROM CountryLanguage where country_code = 'IND' ORDER BY Percentage DESC;
SELECT COUNT(*) FROM CountryLanguage WHERE Language = 'English';
SELECT Population/Surface_Area AS Population_Density FROM Country WHERE name = 'United States';
SELECT SUM(Population) FROM City WHERE Country_Code = 'USA';
SELECT AVG(Life_Expectancy) FROM Country WHERE continent = 'Europe';
SELECT * FROM Country WHERE Name LIKE '%and%';
SELECT * FROM Country WHERE Name LIKE 'And%';