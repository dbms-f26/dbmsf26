
\\\\ClassWork
SELECT * FROM COUNTRY;
SELECT Code, Name FROM Country;
SELECT Code, Name FROM Country ORDER BY Name;
SELECT Code, Name FROM Country ORDER BY Population DESC;
SELECT Life_Expectancy FROM Country WHERE CODE = 'USA';
SELECT * FROM Country WHERE Life_Expectancy > 80;
Select count(*) from Country where Life_Expectancy >80;
select name, gnp/population as gnp_per_capita from country where life_expectancy > 80;
select * from country where name like '%Republic%';
select * from country where name like 'Mac%';

\\\\HomeWork
select population from country where code = 'USA';
select code from country where name = 'India';
select language from countrylanguage where country_code = 'IND' ORDER BY language ASC;
select language from countrylanguage where country_code = 'IND' ORDER BY percentage DESC;
select count(*) from countrylanguage where language = 'English';
select population / surface_area from country where code = 'USA';
select sum(population) from city where country_code = 'USA';
select AVG(Life_expectancy) from country where continent = 'Europe';
select name from country where name like '%and%';
select name from country where name like 'And%';