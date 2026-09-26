--1. Write a query to show the name, independence year and region for the five countries 
--that have most recently become independent. Hint: handle the nulls.

SELECT name, indep_year, region
FROM country
WHERE indep_year IS NOT NULL
ORDER BY indep_year DESC
LIMIT 5;

--2. GNPOld refers to the previous year's Gross National Product. 
--Write a query to show the percentage growth in GNP for countries in North
--and South America, with the fastest-growing economies on top. Show 0 growth 
--whenever GNPOld is unavailable.

SELECT name, CASE WHEN gnp_old IS NULL THEN 0 ELSE (gnp - gnp_old) / gnp_old * 100 END AS gnp_growth
FROM country
WHERE continent IN ('North America', 'South America')
ORDER BY gnp_growth DESC;

--3. Below is a table showing common population density cutoffs for countries. 
--Write a query showing the name and density tier of every country in the world 
--(only these two columns) ordered by continent, region, and alphabetically within each region.

SELECT name, CASE WHEN surface_area = 0 OR population/surface_area < 10 THEN 'Very Low / Sparse'
                  WHEN population/surface_area < 50 THEN 'Low'
                  WHEN population/surface_area < 150 THEN 'Moderate / Medium'
                  WHEN population/surface_area < 500 THEN 'High'
                  ELSE 'Very High / Extreme' END
FROM country
ORDER BY continent, region, name;