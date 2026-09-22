SET search_path TO world;

--How many people live in USA?

SELECT population
FROM country
WHERE code = 'USA';

--What is India’s country code?

SELECT code
FROM country
WHERE name = 'India';

--What languages are spoken in India? Order them alphabetically. 
--(Hint: Look up the country code and query the CountryLanguages table. It’s ok to hardcode to country code.)

SELECT language
FROM countrylanguage
WHERE country_code = 'IND'
ORDER BY language;

--Same list of languages but order them by the percentage of people in India who speak them, in descending order.

SELECT language, percentage
FROM countrylanguage
WHERE country_code = 'IND'
ORDER BY percentage DESC;

--In how many countries is English spoken? (Hint: COUNT(*))

SELECT COUNT(*)
FROM countrylanguage
WHERE language = 'English';

--What is USA’s population density? (Hint: population divided by surface area.)

SELECT population/surface_area 
FROM country
WHERE code = 'USA';

--What is the total population of USA’s cities? (hint: SUM)

SELECT SUM(population)
FROM city
WHERE country_code = 'USA';

--What is the average life expectancy in Europe?

SELECT AVG(life_expectancy)
FROM country
WHERE Continent = 'Europe';
