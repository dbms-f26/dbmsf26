set search_path TO world;

select population from country where code = 'USA'; 

select * from country; 

select code from country where name = 'India';

select language from countrylanguage where country_code = 'IND';

select language,percentage from countrylanguage where country_code = 'IND' order by percentage desc;

select language,percentage from countrylanguage where country_code = 'IND' order by percentage desc;

select population/surface_area from country where code = 'USA'; 

select sum(population) from city where country_code = 'USA'; 

select avg(life_expectancy) from country where code = 'EUR';

select * from country where name like '%and%'; 

select * from country where name like 'And%'; 


