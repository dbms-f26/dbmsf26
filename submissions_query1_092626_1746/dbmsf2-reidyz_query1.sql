SELECT * FROM country WHERE name LIKE '%United States%';
278357000

SELECT * FROM country WHERE name LIKE '%Indi%';
IND

SELECT * FROM countrylanguage WHERE country_code LIKE '%IND%'
ORDER BY language ASC;

SELECT * FROM countrylanguage WHERE country_code LIKE '%IND%'
ORDER BY percentage DESC;

SELECT COUNT(*) FROM countrylanguage WHERE language LIKE '%Eng%';
 77

SELECT AVG(population/surface_area) FROM country;
409.859185816286724056434686

SELECT SUM(population) FROM city WHERE country_code LIKE '%USA%';
78625774

 SELECT AVG(Life_Expectancy) FROM country WHERE continent LIKE '%Europe%';
75.1477272727272727

SELECT * FROM country WHERE name LIKE '%and%';

SELECT * FROM country WHERE name LIKE '%And%';