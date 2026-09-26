select population from country where code = 'USA';
select code from country where name = 'India';
select * from countrylanguage where country_code = 'IND' order by language asc;
select * from countrylanguage where country_code = 'IND' order by percentage desc;
select count(*) from countrylanguage where language = 'English'; 
select population/surface_area as populationdensity from country where code = 'USA';
select SUM(population) from city where country_code = 'USA';
select AVG(life_expectancy) from country where continent = 'Europe';