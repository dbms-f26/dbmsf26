-- HW 5 --

SET search_path TO world;

-- ONE
SELECT Population FROM country WHERE Code = 'USA';
-- TWO & Three
SELECT Language FROM countrylanguage WHERE country_code = 'IND' ORDER BY Language;
-- Four 
Select Language, Percentage From countrylanguage WHERE country_code = 'IND' ORDER BY Percentage DESC;
-- Five  
Select COUNT(*) FROM countrylanguage WHERE Language = 'English';
-- Six 
SELECT Population / Surface_Area AS Population_Density FROM Country WHERE Code = 'USA';
--Seven 
SELECT SUM(population) AS Total_Usa_City_Population FROM city WHERE country_code = 'USA';
-- Eight
SELECT AVG(life_expectancy) AS Average_Life_Expectancy FROM country WHERE continent = 'Europe';
-- Nine 
SELECT name FROM country WHERE name ILIKE '%and%' ORDER BY name;
-- Ten
SELECT name FROM country WHERE name ILIKE 'and%' ORDER BY name;