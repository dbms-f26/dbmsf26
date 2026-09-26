SET search_path TO world;

-- 1. How many people live in USA?
SELECT population FROM country WHERE code = 'USA';

-- 2. What is India's country code?
SELECT code FROM country WHERE name = 'India';

-- 3. What languages are spoken in India? Order them alphabetically.
SELECT language FROM countrylanguage WHERE country_code = 'IND' ORDER BY language;

-- 4. Same list of languages, ordered by percentage of speakers, descending.
SELECT language, percentage FROM countrylanguage WHERE country_code = 'IND' ORDER BY percentage DESC;

-- 5. In how many countries is English spoken?
SELECT COUNT(*) FROM countrylanguage WHERE language = 'English';

-- 6. What is USA's population density? (population divided by surface area)
SELECT population / surface_area AS population_density FROM country WHERE code = 'USA';

-- 7. What is the total population of USA's cities?
SELECT SUM(population) FROM city WHERE country_code = 'USA';

-- 8. What is the average life expectancy in Europe?
SELECT AVG(life_expectancy) FROM country WHERE continent = 'Europe';

-- 9. Get a list of countries whose name includes "and".
SELECT * FROM country WHERE name LIKE '%and%';

-- 10. Get a list of countries whose name starts with "And".
SELECT * FROM country WHERE name LIKE 'And%';