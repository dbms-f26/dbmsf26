-- Examine the code carefully before adding to it.
-- Your project does not have to include all the data in the staging tables.

DROP TABLE IF EXISTS project.student;

CREATE TABLE project.student (
    student_id                varchar(10)  PRIMARY KEY,   -- varchar, not int: IDs such as '091555' have leading zeros
    first_name                varchar(50)  NOT NULL,
    last_name                 varchar(50)  NOT NULL,
    email                     varchar(255) NOT NULL,
    classification            varchar(20) NOT NULL,                -- Freshman / Sophomore / Junior / Senior
    ethnicity                 varchar(100),
    gender                    char(1),
    first_generation          boolean,      -- true when flagged 'First Generation Student'; blank = false
    resident_commuter_status  char(1)       -- R = resident, C = commuter
);

-- The staging table has one row per student per completed activity, so student attributes
-- repeat. DISTINCT collapses them to one row per student. If a student ever appears with
-- conflicting attributes, DISTINCT returns two rows for that student_id and the PRIMARY KEY
-- makes the INSERT fail.

INSERT INTO project.student (
    student_id, first_name, last_name, email, classification,
    ethnicity, gender, first_generation, resident_commuter_status
)
SELECT DISTINCT
    student_id,
    first_name,
    last_name,
    email,
    classification,
    ethnicity,
    gender,
    COALESCE(first_generation = 'First Generation Student', false) AS first_generation,
    resident_commuter_status
FROM project.stg_student_activity;

DROP TABLE IF EXISTS project.studentmajor;
DROP TABLE IF EXISTS project.major;

CREATE TABLE project.major (
    major_id    int      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    major_name  varchar(100) NOT NULL UNIQUE
);

CREATE TABLE project.studentmajor (
    student_id  varchar(10) NOT NULL REFERENCES project.student (student_id),
    major_id    integer     NOT NULL REFERENCES project.major (major_id),
    PRIMARY KEY (student_id, major_id)
);

-- Lookup: one row per distinct individual major. The pattern '\s*;\s*' splits on the
-- semicolon and absorbs the spaces around it. Rows with a NULL major produce no values.
INSERT INTO project.major (major_name)
SELECT DISTINCT regexp_split_to_table(major, '\s*;\s*') AS major_name
FROM project.stg_student_activity;

-- Bridge table: one row per student per individual major.
INSERT INTO project.studentmajor (student_id, major_id)
SELECT DISTINCT s.student_id, m.major_id
FROM (
    SELECT student_id, regexp_split_to_table(major, '\s*;\s*') AS major_name
    FROM project.stg_student_activity
) s
JOIN project.major m ON m.major_name = s.major_name;

-- TO DO: 
-- 1. Handle any other student-level multivalued fields you want to include by creating lookup tables and bridge tables
-- 2. Load data from stg_activity into a new activity table
-- 3. Handle the multivalued competencies field by creating a "competency" table and a bridge table between activities and competencies 
--     (similar to what was done for majors). Convert "levels" to points.
-- 4. Load student_id, activity_id and any other data specific to a student completing an activity from stg_student_activity 
--    into student_activity table
-- 5. Run a join query to confirm you get 23 rows when students are combined with activity completions
-- 6. Check your schema against your schema design. Make necessary changes (on either side) to bring them in sync. 
-- This includes creating additional tables in the schema and populating them with data from the staging tables or your own made-up data
-- It also includes adding/removing things from the schema design. 



