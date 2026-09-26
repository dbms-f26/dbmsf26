select population
from country
where code = 'USA';

select code 
from country
where name = 'India';

select language from countrylanguage
where country_code = 'IND';

select language, percentage
from countrylanguage
where country_code = 'IND'
order by percentage desc;

select count(*) from countrylanguage
where language = 'English';

select name, population/surface_area as density
from country
where code = 'USA';

select sum(population) from city
where country_code = 'USA';

select avg(life_expectancy) from country
where continent = 'Europe';

select name from country
where name like '%and%';

select name from country
where name like 'And%';