SELECT * FROM country WHERE name LIKE '%United States%';


SELECT * FROM country WHERE name LIKE '%India%';
SELECT * FROM country;




SELECT * FROM countrylanguage WHERE country_code LIKE '%IND%'


SELECT * FROM countrylanguage WHERE country_code LIKE '%IND%'
ORDER BY percentage DESC;

SELECT COUNT(*) FROM countrylanguage WHERE language LIKE '%English%';

SELECT AVG(population/surface_area) FROM country;

SELECT SUM(population) FROM city WHERE country_code LIKE '%USA%';

SELECT AVG(life_expectancy) from country WHERE continent LIKE '%Europe%';

SELECT * FROM country WHERE name LIKE '%and%';

SELECT * FROM country WHERE name LIKE '%And%';


select * from country where name like '%United%';