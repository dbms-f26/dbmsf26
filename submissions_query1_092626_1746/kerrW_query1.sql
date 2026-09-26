SET search_path TO world;

SELECT population FROM Country WHERE code = 'USA';

SELECT code FROM Country WHERE name = 'India';

SELECT language FROM countrylanguage WHERE country_code = 'IND' ORDER BY language DESC;

SELECT language FROM countrylanguage WHERE country_code = 'IND' ORDER BY percentage DESC;

SELECT COUNT(*) FROM countrylanguage WHERE language = 'English';

SELECT population / surface_area FROM country WHERE code = 'USA';

SELECT SUM(population) FROM city WHERE country_code = 'USA';

SELECT AVG(life_expectancy) FROM country WHERE continent = 'Europe';

SELECT name FROM country WHERE name LIKE '%and%';

SELECT name FROM country WHERE name LIKE 'And%';
