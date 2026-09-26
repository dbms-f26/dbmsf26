SET search_path TO world;

SELECT Code, Name, Population FROM Country where Code = 'USA';

SELECT Code, Name FROM Country WHERE Name = 'India';

SELECT language FROM countrylanguage WHERE country_code = 'IND';

SELECT language, percentage FROM countrylanguage WHERE country_code = 'IND' ORDER BY Percentage DESC;

SELECT count(*) FROM countrylanguage WHERE language = 'English';

SELECT population/surface_area AS population_density FROM country WHERE Code = 'USA';

SELECT sum(population) FROM city where country_code = 'USA';

SELECT avg(life_expectancy) FROM country where continent = 'Europe';

SELECT name FROM country where Name LIKE '% and %';

SELECT name FROM country where Name LIKE 'And%';