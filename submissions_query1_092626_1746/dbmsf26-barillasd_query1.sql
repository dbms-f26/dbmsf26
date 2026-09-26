SET search_path TO world;

SELECT population from country where code='USA';
SELECT code from country where name='India';
Select LANGUAGE from countrylanguage where country_code='IND';
Select LANGUAGE from countrylanguage where country_code='IND' ORDER BY percentage DESC;
SELECT count(*) from countrylanguage where language like 'English%';
SELECT AVG(population/surface_area) from country where code='USA';
SELECT SUM(population) from city where country_code='USA';
SELECT AVG(life_expectancy) from country where continent = 'Europe';
SELECT * from country where name like '%and%';
SELECT * from country where name like 'And%';