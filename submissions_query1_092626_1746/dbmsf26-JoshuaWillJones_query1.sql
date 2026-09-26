SET search_path TO world;

select population 
from country 
where name = 'United States';

select code
from country 
where name = 'India';

select language
from countrylanguage
where country_code = 'IND'
order by language;

select language
from countrylanguage
where country_code = 'IND'
order by percentage;

select COUNT(*)
from countrylanguage
where language = 'English';

select population/surface_area as Population_Density
from country
where name = 'United States';

select SUM(population)
from city
where country_code = 'USA';

select AVG(life_expectancy)
from country
where continent = 'Europe';

select name
from country
where name LIKE '%and%';

select name
from country
where name LIKE 'And%';
