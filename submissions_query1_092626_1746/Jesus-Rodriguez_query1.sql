--HomeWork

--1
select population from country where code ='USA';

--2
SELECT Code FROM country WHERE Name = 'India';

--3
    Select language From countrylanguage Where country_Code= 'IND' order by language;

--4
Select language, percentage From countrylanguage where country_code= 'IND' order by percentage desc;

--5
select count(*) from countrylanguage where language = 'English';

--6
Select population / surface_area AS population_density from country where code = 'USA';

--7
select sum(population) as total_city_population From city where country_code='USA';

--8
SELECT AVG(life_expectancy) AS avg_life_expectancy FROM world.country WHERE continent = 'Europe';

--9
Select * from country where name LIKE '%and%';

--10
Select * from country where name LIKE 'AND%';
