SELECT Population FROM Country WHERE code = 'USA';

SELECT Code FROM Country WHERE name = 'India';

SELECT Language FROM CountryLanguage WHERE Country_Code = 'IND' ORDER BY Language;

SELECT Language, Percentage FROM CountryLanguage WHERE Country_Code = 'IND' ORDER BY percentage DESC;

SELECT Count(*) FROM CountryLanguage WHERE language = 'English';

SELECT Population/surface_area AS Population_Density FROM Country WHERE code = 'USA';

SELECT Sum(Population) FROM City WHERE Country_Code = 'USA';

SELECT AVG(Life_expectancy) FROM Country WHERE Continent = 'Europe';

SELECT * FROM Country WHERE name LIKE '%and%';

SELECT * FROM Country WHERE name LIKE 'And%';