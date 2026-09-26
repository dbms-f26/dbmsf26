SET search_path TO world;

SELECT population from country where name = 'United States';
--
select code from country WHERE name = 'India';
--
select LANGUAGE from countrylanguage where country_code = 'IND' ORDER BY language;
--
select LANGUAGE from countrylanguage where country_code = 'IND' ORDER BY percentage DESC;
--
select COUNT(*) from countrylanguage where language = 'English';
--
select population / surface_area from country where name = 'USA';
--
select SUM(population) from city where country_code = 'USA';
--
select AVG(Life_expectancy) from country where continent = 'Europe';
--
select * from Country WHERE name like '%and%';
--
SELECT * FROM Country WHERE name LIKE 'And%';
