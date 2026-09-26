SET search_path TO world;
-- USA's population
SELECT name, population FROM country WHERE code = 'USA';
-- India's country code
SELECT name, code FROM country WHERE name = 'India';
-- Languages spoken in India
SELECT country_code, language FROM countrylanguage WHERE country_code = 'IND';
-- Ordered languages spoken in India
SELECT country_code, language FROM countrylanguage WHERE country_code = 'IND' ORDER BY PERCENTAGE DESC;
-- Amount of countries that speak english
SELECT COUNT(*) FROM countrylanguage WHERE language = 'English';
-- Population density of the USA
SELECT name, population/surface_area AS population_density FROM country WHERE code = 'USA';
-- Sum of city population in the USA
SELECT SUM(population) FROM city WHERE country_code = 'USA';
-- Average life expectancy of Europe
SELECT AVG(life_expectancy) FROM country WHERE continent = 'Europe';
-- Countries with "and" in their name
SELECT name FROM country WHERE name LIKE '%and%';
-- Countries that start with "And"-
SELECT name FROM country WHERE name LIKE 'And%';
