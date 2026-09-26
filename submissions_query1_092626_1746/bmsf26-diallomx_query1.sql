Set search_path TO world;

Select population from Country where code = 'USA';

Select code from country where name like '%India %';

Select  LANGUAGE
 from countrylanguage
 where country_code = 'IND';

Select Language, percentage
 from countrylanguage
 where country_code = 'IND'
 order by percentage DESC;

Select count(country_code) 
 from countrylanguage
 where language = 'English';

Select population/surface_area from Country where code = 'USA';

Select SUM (POPULATION)
 from city 
 where country_code= 'USA';

Select  AVG(life_expectancy) 
 from country 
 where continent = 'Europe';

Select * From country where Name Like '%and%';
Select * From country where Name Like '%And%';