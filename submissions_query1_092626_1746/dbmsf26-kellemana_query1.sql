SET search_path TO world;

--1
SELECT Population FROM Country WHERE CODE = 'USA';

--2
SELECT Code FROM Country WHERE Name = 'India';

--3
SELECT language FROM countrylanguage WHERE country_code = 'IND';

--4
SELECT language, percentage FROM countrylanguage WHERE country_code = 'IND' ORDER BY percentage DESC;

--5
SELECT COUNT(*) FROM countrylanguage WHERE language = 'English'; 

--6
SELECT name, population/surface_area AS Population_Density FROM country WHERE Code = 'USA';

--7
SELECT SUM(population) FROM CITY WHERE country_code = 'USA';

--8
SELECT AVG(life_expectancy) FROM country WHERE continent = 'Europe';

--9
SELECT name FROM Country WHERE Name LIKE '% and %';

--10
SELECT name FROM Country WHERE Name Like 'And%';
