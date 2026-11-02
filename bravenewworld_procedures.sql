
SET search_path TO bravenewworld;

-- backup the tables so you can restore them after testing your procedure
CREATE TABLE country_bkup AS SELECT * FROM country;
CREATE TABLE city_bkup AS SELECT * FROM city;
CREATE TABLE cl_bkup AS SELECT * FROM countrylanguage;
CREATE TABLE l_bkup AS SELECT * FROM language;

-- This procedure will allow one country to conquer another. 
-- The aggressor will take over the victim's cities, and the aggressor's population and surface area will be updated to include the victim's. 
-- The languages spoken in both countries will be combined, with any language that was official in either country becoming official in the new country. 
-- The victim country will be deleted from the database.
-- Parameters: VAGGRESSOR is the country code of the aggressor, VVICTIM is the country code of the victim
CREATE OR REPLACE procedure CONQUER (IN VAGGRESSOR VARCHAR(3), IN VVICTIM VARCHAR(3))
LANGUAGE plpgsql AS $$
DECLARE
    VSURF FLOAT; -- total surface area of the two countries
    VPOP INT; -- total population of the two countries
BEGIN
    BEGIN
        /* 2. Get the *total* surface area and population of the two countries and store them in variables VSURF and VPOP*/
        SELECT SUM(surface_area), SUM(population) INTO VSURF, VPOP FROM country WHERE Code IN (VAGGRESSOR, VVICTIM); 

        /* 3. Get the total number of people who speak every language spoken in either country and store in a table called languagelist.
        Any language that was official in either country should become official in the new country. */
        CREATE TABLE languagelist AS
        SELECT A.language_id, (SUM(population * percentage)) AS speakers, BOOL_OR(A.is_official) AS is_official
        FROM countrylanguage A
        JOIN country B ON A.country_code = B.code
        WHERE A.country_code IN (VAGGRESSOR, VVICTIM)
        GROUP BY A.language_id;

        /* 4. Reassign the victim's cities to the aggressor */
        UPDATE city
        SET country_code = VAGGRESSOR
        WHERE country_code = VVICTIM;

        /* 5. Update the population and surface area of the aggressor to VSURF and VPOP.*/
        UPDATE country 
        SET surface_area = VSURF, population = VPOP 
        WHERE code = VAGGRESSOR;

        /* 6. Delete both countries' countrylanguage records*/
        DELETE FROM countrylanguage WHERE country_code IN (VAGGRESSOR, VVICTIM);

        /* 7. Delete the victim country*/
        DELETE FROM country WHERE code = VVICTIM;

        /* 8. Insert the updated language information into countrylanguage */
        INSERT INTO countrylanguage (country_code, language_id, percentage, is_official)
        SELECT VAGGRESSOR, language_id, speakers/VPOP, is_official
        FROM languagelist;

        /*9. drop languagelist.*/
        DROP TABLE languagelist;

    EXCEPTION
        -- If any error occurs, roll back the transaction and raise a notice with the error message
        WHEN OTHERS THEN
            RAISE NOTICE '% could not conquer %: %', VAGGRESSOR, VVICTIM, QLERRM;
        ROLLBACK;
    END;
    -- If everything was successful, commit the transaction and raise a notice indicating that the conquest was successful
    COMMIT;
    RAISE NOTICE '% has been conquered by %', VVICTIM, VAGGRESSOR;
END;
$$;

/* call the procedure */
CALL CONQUER('USA','CAN');

/* Check that it worked */

/* Has Canada disappeared? Is the USA population 309 million?*/
SELECT * FROM country WHERE Code IN ('USA','CAN');

/* Are there now 16 languages spoken in USA, with English at 83.6%, and both English and French as official languages? */
SELECT * 
FROM countrylanguage A, language B
WHERE A.Language_ID = B.Language_ID AND A.Country_Code IN ('USA','CAN')
ORDER BY Percentage DESC;

/* Does USA now have 323 cities, with Montreal at #10? */
SELECT * FROM city WHERE Country_Code IN ('USA','CAN') ORDER BY Country_Code, Population DESC;

/*restore from backup*/
SET search_path TO bravenewworld;

delete from countrylanguage;
delete from city;
delete from country;

INSERT INTO country
SELECT * FROM country_bkup;

INSERT INTO countrylanguage
SELECT * FROM cl_bkup;

INSERT INTO city
SELECT * FROM city_bkup;

-- country_merge procedure: This procedure will allow multiple countries to be merged into a new country.
-- The new country will have a specified code, name, and head of state. 
-- The procedure will leverage the existing conquer procedure to merge the specified countries into the new country.
-- Parameters:
-- p_countries: An array of country codes to be merged.
-- p_code: The code for the new country.
-- p_name: The name for the new country.
-- p_head_of_state: The head of state for the new country.
CREATE OR REPLACE PROCEDURE country_merge(
    p_countries VARCHAR[],
    p_code VARCHAR,
    p_name VARCHAR,
    p_head_of_state VARCHAR
) LANGUAGE plpgsql AS $$
DECLARE
    v_country_count INT;
BEGIN
    BEGIN
    -- 1. Calculate the number of countries to be merged and store it in v_country_count
    v_country_count := array_length(p_countries, 1);

    -- 2. Insert the new country into the country table with the specified code, name, and head of state
    INSERT INTO country (code, name, head_of_state) VALUES (p_code, p_name, p_head_of_state);

    -- 3. Loop through the array of countries and call the conquer procedure for each one, merging them into the new country
    FOR i IN 1..v_country_count LOOP
        CALL conquer(p_code, p_countries[i]);
    END LOOP;

    -- 4. If any error occurs during the merge process, roll back the transaction and raise a notice with the error message
    EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Country merge failed for %: %', p_name, SQLERRM;
        ROLLBACK;
    END; 
    -- 5. If everything was successful, commit the transaction and raise a notice indicating that the new country has been created
    COMMIT;
    RAISE NOTICE 'The combined nation of % has been created.', p_name;
END;
$$;

SELECT code, name FROM country WHERE code IN ('ATA', 'DEU', 'USA', 'ALB', 'GRC', 'VAT');

SELECT * FROM countrylanguage WHERE country_code IN ('ATA', 'DEU', 'USA', 'ALB', 'GRC', 'VAT');

SELECT * FROM city WHERE country_code IN ('ATA', 'DEU', 'USA', 'ALB', 'GRC', 'VAT');

CALL country_merge(ARRAY['ATA', 'DEU', 'USA', 'ALB', 'GRC', 'VAT'], 'NAA', 'New Antarctica', 'President Nora Sekol');

--should return 0 rows
SELECT code, name FROM country WHERE code IN ('ATA', 'DEU', 'USA', 'ALB', 'GRC', 'VAT');

SELECT * FROM city WHERE country_code IN ('ATA', 'DEU', 'USA', 'ALB', 'GRC', 'VAT');

SELECT * FROM countrylanguage WHERE country_code IN ('ATA', 'DEU', 'USA', 'ALB', 'GRC', 'VAT');

-- should return one row for New Antarctica with Nora Sekol as President and population and surface area 
-- equal to the total population and surface area of the merged countries
SELECT * FROM country WHERE code = 'NAA';

-- should return languages spoken in New Antarctica with a calculated percentage of speakers for each language
SELECT * FROM countrylanguage WHERE country_code = 'NAA';

-- should return cities in New Antarctica matching the cities of the merged countries
SELECT * FROM city WHERE country_code = 'NAA';
