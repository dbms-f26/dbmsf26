-- This script deletes and recreates the project schema and populates two staging tables with 
-- data from activity.xlsx and student_activity.xlsx

-- Staging conventions
--   * Every source column is TEXT: values are loaded as-is, with no typing or cleansing.
--   * Blank cells are NULL, but literal text like 'None' is preserved as is (handle this downstream)
--   * Dates/times that Excel stored as native date/time values were written out in the
--     same text format as the rest of their column (MM/DD/YYYY, H:MM AM).
--   * No keys or constraints, so every source row loads (including any duplicates).

DROP SCHEMA IF EXISTS project;

CREATE SCHEMA IF NOT EXISTS project;

-- activity.xlsx / Activities  (source header 'ID' is renamed activity_id)
DROP TABLE IF EXISTS project.stg_activity;
CREATE TABLE project.stg_activity (
    title                      text,
    activity_id                text,
    description                text,
    type                       text,
    level                      text,
    competencies               text,
    incentive                  text,
    requires_submission        text,
    requires_qr_code           text,
    requires_reflection        text,
    requires_approval          text,
    start_date                 text,
    start_time                 text,
    end_date                   text,
    end_time                   text,
    time_zone                  text,
    location                   text,
    reserved                   text,
    activities_tags            text,
    -- load metadata
    source_file                text        NOT NULL,
    source_row                 integer     NOT NULL,   -- spreadsheet row number (header = row 1)
    loaded_at                  timestamptz NOT NULL DEFAULT now()
);

-- student_activity.xlsx / Sheet1  (source header 'ID' is named student_id; kept as text to preserve leading zeros)
DROP TABLE IF EXISTS project.stg_student_activity;
CREATE TABLE project.stg_student_activity (
    first_name                 text,
    last_name                  text,
    email                      text,
    student_id                 text,
    date_completed             text,
    classification             text,
    athletic_teams             text,
    career_strategist          text,
    entry_term                 text,
    ethnicity                  text,
    first_generation           text,
    gender                     text,
    greek_org                  text,
    major                      text,
    minor                      text,
    resident_commuter_status   text,
    activity_title             text,
    activity_id                text,
    activity_type              text,
    start_time                 text,
    end_time                   text,
    level                      text,
    competencies               text,
    activities_tags            text,
    -- load metadata
    source_file                text        NOT NULL,
    source_row                 integer     NOT NULL,   -- spreadsheet row number (header = row 1)
    loaded_at                  timestamptz NOT NULL DEFAULT now()
);

-- -----------------------------------------------------------------------------
-- Load: project.stg_activity  (16 rows)
-- -----------------------------------------------------------------------------
INSERT INTO project.stg_activity (title, activity_id, description, type, level, competencies, incentive, requires_submission, requires_qr_code, requires_reflection, requires_approval, start_date, start_time, end_date, end_time, time_zone, location, reserved, activities_tags, source_file, source_row) VALUES
    ('Follow @mucareersuccess on Instagram', '615278', 'Ready to March Into Elevate? Follow us on Instagram for regular updates and progress reports. Attach a screenshot showing that you follow us to earn 10 points towards Technology.', 'task', 'Level 1', 'Technology', 'None', 'Yes', 'No', 'No', 'Yes', '03/01/2026', '12:00 AM', '03/01/2026', '11:59 PM', 'America/New_York', 'None', NULL, 'March into Elevate 2026', 'activity.xlsx', 2),
    ('Share what Elevate means to you', '615289', 'How would you describe Elevate to an incoming Moravian student? Write a brief one paragraph reflection that shares information about Elevate and why it can be beneficial to Moravian students. Earn 10 points towards Critical Thinking and 10 points towards Leadership.', 'task', 'Level 1', 'Critical Thinking; Leadership', 'None', 'No', 'No', 'Yes', 'Yes', '03/02/2026', '12:00 AM', '03/02/2026', '11:59 PM', 'America/New_York', 'None', NULL, 'March into Elevate 2026', 'activity.xlsx', 3),
    ('Share your favorite quote about leadership', '615291', 'Share your favorite quote about leadership in the reflection box. Why did you choose it? What does it mean to you?  Share the quote and write a 3-5 sentence reflection to earn 10 points towards Leadership.', 'task', 'Level 1', 'Leadership', 'None', 'No', 'No', 'Yes', 'Yes', '03/03/2026', '12:00 AM', '03/03/2026', '11:59 PM', 'America/New_York', 'None', NULL, 'March into Elevate 2026', 'activity.xlsx', 4),
    ('Apply for your passport and upload your materials to your AMOS travel portal', '615293', 'Use today to get a headstart on your travel goals! Gather your passport application materials and apply for your passport at your local USPS location. Upload proof of progress (confirmation of upload on AMOS, passport photo, finished passport cover, confirmation email, etc.) to earn 10 points towards Communication and 10 points towards Equity & Inclusion. (Please do not share personal or identifying information in your upload.)', 'task', 'Level 1', 'Communication; Equity & Inclusion', 'None', 'Yes', 'No', 'No', 'Yes', '03/04/2026', '12:00 AM', '03/04/2026', '11:59 PM', 'America/New_York', 'None', NULL, 'March into Elevate 2026', 'activity.xlsx', 5),
    ('Talk with a Moravian student or alumni who has traveled abroad', '615385', 'Talk with a Moravian student or alumni who traveled/studied abroad while in college. Who was the student? How was their experience? What did they learn? Would they recommend it to another student? Write a one paragraph reflection answering all of the questions in the prompt to earn 10 points towards Teamwork and 10 points towards Equity & Inclusion.', 'task', 'Level 1', 'Equity & Inclusion; Teamwork', 'None', 'No', 'No', 'Yes', 'Yes', '03/20/2026', '12:00 AM', '03/20/2026', '11:59 PM', 'America/New_York', 'None', NULL, 'March into Elevate 2026', 'activity.xlsx', 6),
    ('Attend today''s virtual Global Greyhound Information Session', '617994', E'The first step towards your Global Greyhound trip is attending an information session! Learn about your Elevate travel voucher, how to get a passport, and what to expect on a future trip. Students should scan the QR code at the end of the presentation to earn 10 points towards Equity & Inclusion and 10 points towards Critical Thinking. \n\n**Global Greyhound Information Session | 4:00 PM | March 25, 2026 | Zoom Link Below**', 'event', 'Level 1', 'Critical Thinking; Equity & Inclusion', 'None', 'No', 'Yes', 'No', 'Yes', '03/25/2026', '12:00 AM', '03/25/2026', '11:59 PM', 'America/New_York', 'Zoom (link in activity)', NULL, 'March into Elevate 2026', 'activity.xlsx', 7),
    ('Attend Activate Your Elevate (Career Edition) | Noon - 1pm, PPHAC 117', '619234', 'As we wrap up our March Into Elevate daily challenges, it''s time to learn how to show off your hard work! Attend this one-hour information session to learn more about how you can showcase and speak about your Elevate experience at Moravian to employers, graduate schools, and professional connections. Join us from 12 - 1:00pm today in PPHAC 117. Earn 20 points towards Teamwork and 20 points toward Critical Thinking.', 'event', 'Level 2', 'Critical Thinking; Teamwork', 'None', 'No', 'Yes', 'No', 'Yes', '03/31/2026', '12:00 AM', '03/31/2026', '11:59 PM', 'America/New_York', 'PPHAC 117', NULL, 'March into Elevate 2026', 'activity.xlsx', 8),
    ('Class of 2028: Attend Halfway Hype!', '638482', E'Come celebrate being halfway to graduation with the Riley Center for Career Success and meet with your 3rd and 4th Year Career Success Team!  Enjoy free food & a photo booth, chat with your new Career Success Team, and network with local employers that have opportunities for YOU!\n\n** April 13 | 2-4pm |  HUB 3rd Floor Balcony**', 'event', 'Level 1', 'Career & Self-Development', 'None', 'No', 'Yes', 'No', 'Yes', '04/13/2026', '1:55 PM', '04/13/2026', '4:10 PM', 'America/New_York', 'HUB 3rd Floor Balcony', NULL, 'Campus Events; Second-Year Student', 'activity.xlsx', 9),
    ('Complete the Career Success End of Year Survey', '643433', 'Complete this end-of-year Career Succes survey to let our team know what you liked, what we could improve, and how we can best support you in future semesters! Upload a screenshot of to show proof of completion and earn 10 points towards Communication.', 'task', 'Level 1', 'Communication', 'None', 'Yes', 'No', 'No', 'Yes', 'None', 'None', '05/31/2026', '12:00 AM', 'America/New_York', 'None', NULL, NULL, 'activity.xlsx', 10),
    ('Class of 2030: Download the Suitable app and set up your account', '646837', 'Class of 2030: Download the Suitable app and set up your account', 'task', 'Level 1', 'Teamwork', 'None', 'No', 'No', 'No', 'Yes', '06/10/2026', '12:00 AM', '10/05/2026', '11:59 PM', 'America/New_York', 'None', NULL, NULL, 'activity.xlsx', 11),
    ('Class of 2030: Share one goal for your first year at Moravian and 3 steps you can take to achieve it', '646838', 'Class of 2030: Share one goal for your first year at Moravian and 3 steps you can take to achieve it', 'task', 'Level 1', 'Equity & Inclusion; Leadership', 'None', 'No', 'No', 'No', 'Yes', '06/11/2026', '12:00 AM', '10/05/2026', '11:59 PM', 'America/New_York', 'None', NULL, NULL, 'activity.xlsx', 12),
    ('Class of 2030: Create your Handshake profile', '646839', 'Class of 2030: Create your Handshake profile', 'task', 'Level 1', 'Professionalism', 'None', 'No', 'No', 'No', 'Yes', '06/12/2026', '12:00 AM', '10/05/2026', '11:59 PM', 'America/New_York', 'None', NULL, NULL, 'activity.xlsx', 13),
    ('Class of 2030: Receive your Apple technology', '646840', 'Class of 2030: Receive your Apple technology', 'task', 'Level 1', 'Technology', 'None', 'No', 'No', 'No', 'Yes', '06/13/2026', '12:00 AM', '10/05/2026', '11:59 PM', 'America/New_York', 'None', NULL, NULL, 'activity.xlsx', 14),
    ('Class of 2030: Identify the three staff members on your Career Success Team that you can meet with this year', '646841', 'Class of 2030: Identify the three staff members on your Career Success Team that you can meet with this year', 'task', 'Level 1', 'Critical Thinking', 'None', 'No', 'No', 'No', 'Yes', '06/14/2026', '12:00 AM', '10/05/2026', '11:59 PM', 'America/New_York', 'None', NULL, NULL, 'activity.xlsx', 15),
    ('Class of 2030: Attend the "Gearing Up For Your Future" Orientation Session', '646842', 'Class of 2030: Attend the "Gearing Up For Your Future" Orientation Session', 'event', 'Level 1', 'Communication', 'None', 'No', 'No', 'No', 'Yes', '06/15/2026', '8:00 AM', '08/30/2026', '4:15 PM', 'America/New_York', 'None', NULL, NULL, 'activity.xlsx', 16),
    ('TED - Why We Have Too Few Women Leaders', '647220', 'TED - Why We Have Too Few Women Leaders', 'task', 'Level 1', 'Equity & Inclusion; Leadership', 'None', 'No', 'No', 'No', 'Yes', 'None', 'None', 'None', 'None', 'America/New_York', 'None', NULL, NULL, 'activity.xlsx', 17);

-- -----------------------------------------------------------------------------
-- Load: project.stg_student_activity  (32 rows)
-- -----------------------------------------------------------------------------
INSERT INTO project.stg_student_activity (first_name, last_name, email, student_id, date_completed, classification, athletic_teams, career_strategist, entry_term, ethnicity, first_generation, gender, greek_org, major, minor, resident_commuter_status, activity_title, activity_id, activity_type, start_time, end_time, level, competencies, activities_tags, source_file, source_row) VALUES
    ('Ashley', 'Akton', 'AktonA@moravian.edu', '577555', '08/30/2026 03:14 PM', 'Freshman', NULL, NULL, '2026-2027 - FALL TERM', 'Hispanics of any race', NULL, 'F', NULL, 'Sociology', NULL, 'R', 'Class of 2030: Attend the "Gearing Up For Your Future" Orientation Session', '646842', 'EVENT', '08/30/2026 08:00 AM', '08/30/2026 04:15 PM', 'Level 1', 'Communication', NULL, 'student_activity.xlsx', 2),
    ('Diane', 'Akton', 'AktonD@moravian.edu', '374565', '08/25/2026 10:22 AM', 'Freshman', NULL, NULL, '2026-2027 - FALL TERM', 'Black or African American', NULL, 'F', NULL, 'Accounting', NULL, 'R', 'Class of 2030: Share one goal for your first year at Moravian and 3 steps you can take to achieve it', '646838', 'TASK', '06/10/2026 12:00 AM', '10/05/2026 11:59 PM', 'Level 1', 'Equity & Inclusion; Leadership', 'First-Year Student', 'student_activity.xlsx', 3),
    ('Diane', 'Akton', 'AktonD@moravian.edu', '374565', '08/30/2026 03:14 PM', 'Freshman', NULL, NULL, '2026-2027 - FALL TERM', 'Black or African American', NULL, 'F', NULL, 'Accounting', NULL, 'R', 'Class of 2030: Attend the "Gearing Up For Your Future" Orientation Session', '646842', 'EVENT', '08/30/2026 08:00 AM', '08/30/2026 04:15 PM', 'Level 1', 'Communication', NULL, 'student_activity.xlsx', 4),
    ('Emma', 'Akton', 'AktonE@moravian.edu', '405545', '06/22/2026 12:31 PM', 'Senior', NULL, 'Alexis Kersten', '2023-2024 - FALL TERM', 'Hispanics of any race', NULL, 'F', NULL, 'Sociology', 'Anthropology; French', 'R', 'TED - Why We Have Too Few Women Leaders', '647220', 'TASK', NULL, NULL, 'Level 1', 'Equity & Inclusion; Leadership', 'Online/Asynchronous', 'student_activity.xlsx', 5),
    ('Jack', 'Berkowitz', 'BerkowitzJ@moravian.edu', '636555', '08/30/2026 02:42 PM', 'Freshman', 'Men''s Football', NULL, '2026-2027 - FALL TERM', 'Race and Ethnicity unknown', NULL, 'M', NULL, 'Undeclared', NULL, 'R', 'Class of 2030: Attend the "Gearing Up For Your Future" Orientation Session', '646842', 'EVENT', '08/30/2026 08:00 AM', '08/30/2026 04:15 PM', 'Level 1', 'Communication', NULL, 'student_activity.xlsx', 6),
    ('Jack', 'Bloom', 'BloomJ@moravian.edu', '522565', '08/30/2026 02:42 PM', 'Freshman', NULL, NULL, '2026-2027 - FALL TERM', 'White', 'First Generation Student', 'M', NULL, 'Aviation Management', NULL, 'R', 'Class of 2030: Attend the "Gearing Up For Your Future" Orientation Session', '646842', 'EVENT', '08/30/2026 08:00 AM', '08/30/2026 04:15 PM', 'Level 1', 'Communication', NULL, 'student_activity.xlsx', 7),
    ('Adam', 'Clinton', 'ClintonA@moravian.edu', '573555', '08/30/2026 03:45 PM', 'Freshman', 'Men''s Football', NULL, '2026-2027 - FALL TERM', 'White', NULL, 'M', NULL, 'Undeclared', NULL, 'R', 'Class of 2030: Attend the "Gearing Up For Your Future" Orientation Session', '646842', 'EVENT', '08/30/2026 08:00 AM', '08/30/2026 04:15 PM', 'Level 1', 'Communication', NULL, 'student_activity.xlsx', 8),
    ('Coley', 'Clinton', 'ClintonC@moravian.edu', '333555', '08/30/2026 02:43 PM', 'Freshman', NULL, NULL, '2026-2027 - FALL TERM', 'White', NULL, 'M', NULL, 'Accounting', NULL, 'R', 'Class of 2030: Attend the "Gearing Up For Your Future" Orientation Session', '646842', 'EVENT', '08/30/2026 08:00 AM', '08/30/2026 04:15 PM', 'Level 1', 'Communication', NULL, 'student_activity.xlsx', 9),
    ('Emma', 'Clinton', 'ClintonE@moravian.edu', '701565', '08/30/2026 02:42 PM', 'Freshman', NULL, NULL, '2026-2027 - FALL TERM', 'White', NULL, 'F', NULL, 'Aviation Management', NULL, 'R', 'Class of 2030: Attend the "Gearing Up For Your Future" Orientation Session', '646842', 'EVENT', '08/30/2026 08:00 AM', '08/30/2026 04:15 PM', 'Level 1', 'Communication', NULL, 'student_activity.xlsx', 10),
    ('Rita', 'Clinton', 'ClintonR@moravian.edu', '339555', '06/24/2026 08:07 PM', 'Freshman', 'Women''s Lacrosse', NULL, '2026-2027 - FALL TERM', 'White', 'First Generation Student', 'F', NULL, 'Undeclared', NULL, 'R', 'Class of 2030: Create your Handshake profile', '646839', 'TASK', '06/10/2026 12:00 AM', '10/05/2026 11:59 PM', 'Level 1', 'Professionalism', 'First-Year Student', 'student_activity.xlsx', 11),
    ('Rita', 'Clinton', 'ClintonR@moravian.edu', '339555', '06/24/2026 08:06 PM', 'Freshman', 'Women''s Lacrosse', NULL, '2026-2027 - FALL TERM', 'White', 'First Generation Student', 'F', NULL, 'Undeclared', NULL, 'R', 'Class of 2030: Receive your Apple technology', '646840', 'TASK', '06/10/2026 12:00 AM', '10/05/2026 11:59 PM', 'Level 1', 'Technology', 'First-Year Student', 'student_activity.xlsx', 12),
    ('Rita', 'Clinton', 'ClintonR@moravian.edu', '339555', '08/30/2026 03:45 PM', 'Freshman', 'Women''s Lacrosse', NULL, '2026-2027 - FALL TERM', 'White', 'First Generation Student', 'F', NULL, 'Undeclared', NULL, 'R', 'Class of 2030: Attend the "Gearing Up For Your Future" Orientation Session', '646842', 'EVENT', '08/30/2026 08:00 AM', '08/30/2026 04:15 PM', 'Level 1', 'Communication', NULL, 'student_activity.xlsx', 13),
    ('Alan', 'Dickson', 'DicksonA@moravian.edu', '091555', '03/25/2026 04:21 PM', 'Sophomore', NULL, NULL, '2025-2026 - FALL TERM', 'White', NULL, 'M', NULL, 'Aviation Management; Philosophy', NULL, 'C', 'Attend today''s virtual Global Greyhound Information Session', '617994', 'EVENT', '03/25/2026 12:00 AM', '03/25/2026 11:59 PM', 'Level 1', 'Equity & Inclusion; Critical Thinking', 'March into Elevate 2026', 'student_activity.xlsx', 14),
    ('Ashley', 'Plantagenet', 'PlantagenetA@moravian.edu', '095555', '03/01/2026 05:33 PM', 'Sophomore', NULL, NULL, '2025-2026 - FALL TERM', 'White', 'First Generation Student', 'F', NULL, 'History', NULL, 'R', 'Follow @mucareersuccess on Instagram', '615278', 'TASK', '03/01/2026 12:00 AM', '03/01/2026 11:59 PM', 'Level 1', 'Technology', 'March into Elevate 2026', 'student_activity.xlsx', 15),
    ('Ashley', 'Plantagenet', 'PlantagenetA@moravian.edu', '095555', '03/25/2026 04:19 PM', 'Sophomore', NULL, NULL, '2025-2026 - FALL TERM', 'White', 'First Generation Student', 'F', NULL, 'History', NULL, 'R', 'Attend today''s virtual Global Greyhound Information Session', '617994', 'EVENT', '03/25/2026 12:00 AM', '03/25/2026 11:59 PM', 'Level 1', 'Equity & Inclusion; Critical Thinking', 'March into Elevate 2026', 'student_activity.xlsx', 16),
    ('Kim', 'Plantagenet', 'PlantagenetK@moravian.edu', '547545', '03/03/2026 06:48 PM', 'Senior', NULL, 'Amy Hudock', '2023-2024 - FALL TERM', 'White', 'First Generation Student', 'F', NULL, 'Sociology', 'Media Studies; Spanish', 'R', 'Share your favorite quote about leadership', '615291', 'TASK', '03/03/2026 12:00 AM', '03/03/2026 11:59 PM', 'Level 1', 'Leadership', 'March into Elevate 2026', 'student_activity.xlsx', 17),
    ('Kim', 'Plantagenet', 'PlantagenetK@moravian.edu', '547545', '06/24/2026 09:37 AM', 'Senior', NULL, 'Amy Hudock', '2023-2024 - FALL TERM', 'White', 'First Generation Student', 'F', NULL, 'Sociology', 'Media Studies; Spanish', 'R', 'TED - Why We Have Too Few Women Leaders', '647220', 'TASK', NULL, NULL, 'Level 1', 'Equity & Inclusion; Leadership', 'Online/Asynchronous', 'student_activity.xlsx', 18),
    ('Mark', 'Plantagenet', 'PlantagenetM@moravian.edu', '557555', '08/30/2026 02:43 PM', 'Freshman', 'Men''s Football', NULL, '2026-2027 - FALL TERM', 'White', 'First Generation Student', 'M', NULL, 'Aviation Management', NULL, 'R', 'Class of 2030: Attend the "Gearing Up For Your Future" Orientation Session', '646842', 'EVENT', '08/30/2026 08:00 AM', '08/30/2026 04:15 PM', 'Level 1', 'Communication', NULL, 'student_activity.xlsx', 19),
    ('Alan', 'Richardson', 'RichardsonA@moravian.edu', '602565', '08/30/2026 03:13 PM', 'Freshman', 'Men''s Basketball', NULL, '2026-2027 - FALL TERM', 'White', 'First Generation Student', 'M', NULL, 'Accounting', NULL, 'R', 'Class of 2030: Attend the "Gearing Up For Your Future" Orientation Session', '646842', 'EVENT', '08/30/2026 08:00 AM', '08/30/2026 04:15 PM', 'Level 1', 'Communication', NULL, 'student_activity.xlsx', 20),
    ('Harry', 'Richardson', 'RichardsonH@moravian.edu', '534565', '08/30/2026 02:42 PM', 'Freshman', NULL, NULL, '2026-2027 - FALL TERM', 'White', NULL, 'M', NULL, 'Accounting', NULL, 'R', 'Class of 2030: Attend the "Gearing Up For Your Future" Orientation Session', '646842', 'EVENT', '08/30/2026 08:00 AM', '08/30/2026 04:15 PM', 'Level 1', 'Communication', NULL, 'student_activity.xlsx', 21),
    ('Jaclyn', 'Richardson', 'RichardsonJ@moravian.edu', '016565', '08/30/2026 02:42 PM', 'Freshman', NULL, NULL, '2026-2027 - FALL TERM', 'Race and Ethnicity unknown', 'First Generation Student', 'F', NULL, 'History', NULL, 'R', 'Class of 2030: Attend the "Gearing Up For Your Future" Orientation Session', '646842', 'EVENT', '08/30/2026 08:00 AM', '08/30/2026 04:15 PM', 'Level 1', 'Communication', NULL, 'student_activity.xlsx', 22),
    ('Adam', 'Stewart', 'StewartA@moravian.edu', '770545', '03/01/2026 02:27 PM', 'Senior', NULL, 'Amy Hudock', '2023-2024 - FALL TERM', 'White', NULL, 'M', NULL, 'Historical Studies', 'Political Science', 'R', 'Follow @mucareersuccess on Instagram', '615278', 'TASK', '03/01/2026 12:00 AM', '03/01/2026 11:59 PM', 'Level 1', 'Technology', 'March into Elevate 2026', 'student_activity.xlsx', 23),
    ('Ashley', 'Stewart', 'StewartA@moravian.edu', '326555', '08/24/2026 10:56 AM', 'Freshman', NULL, NULL, '2026-2027 - FALL TERM', 'White', 'First Generation Student', 'F', NULL, 'Art Education', NULL, 'C', 'Class of 2030: Download the Suitable app and set up your account', '646837', 'TASK', '06/10/2026 12:00 AM', '10/05/2026 11:59 PM', 'Level 1', 'Teamwork', 'First-Year Student', 'student_activity.xlsx', 24),
    ('Ashley', 'Stewart', 'StewartA@moravian.edu', '326555', '08/24/2026 11:00 AM', 'Freshman', NULL, NULL, '2026-2027 - FALL TERM', 'White', 'First Generation Student', 'F', NULL, 'Art Education', NULL, 'C', 'Class of 2030: Share one goal for your first year at Moravian and 3 steps you can take to achieve it', '646838', 'TASK', '06/10/2026 12:00 AM', '10/05/2026 11:59 PM', 'Level 1', 'Equity & Inclusion; Leadership', 'First-Year Student', 'student_activity.xlsx', 25),
    ('Ashley', 'Stewart', 'StewartA@moravian.edu', '326555', '08/24/2026 10:53 AM', 'Freshman', NULL, NULL, '2026-2027 - FALL TERM', 'White', 'First Generation Student', 'F', NULL, 'Art Education', NULL, 'C', 'Class of 2030: Create your Handshake profile', '646839', 'TASK', '06/10/2026 12:00 AM', '10/05/2026 11:59 PM', 'Level 1', 'Professionalism', 'First-Year Student', 'student_activity.xlsx', 26),
    ('Ashley', 'Stewart', 'StewartA@moravian.edu', '326555', '08/24/2026 11:01 AM', 'Freshman', NULL, NULL, '2026-2027 - FALL TERM', 'White', 'First Generation Student', 'F', NULL, 'Art Education', NULL, 'C', 'Class of 2030: Receive your Apple technology', '646840', 'TASK', '06/10/2026 12:00 AM', '10/05/2026 11:59 PM', 'Level 1', 'Technology', 'First-Year Student', 'student_activity.xlsx', 27),
    ('Ashley', 'Stewart', 'StewartA@moravian.edu', '326555', '08/24/2026 11:03 AM', 'Freshman', NULL, NULL, '2026-2027 - FALL TERM', 'White', 'First Generation Student', 'F', NULL, 'Art Education', NULL, 'C', 'Class of 2030: Identify the three staff members on your Career Success Team that you can meet with this year', '646841', 'TASK', '06/10/2026 12:00 AM', '10/05/2026 11:59 PM', 'Level 1', 'Critical Thinking', 'First-Year Student', 'student_activity.xlsx', 28),
    ('Geneva', 'Stewart', 'StewartG@moravian.edu', '173555', '08/30/2026 02:42 PM', 'Freshman', NULL, NULL, '2026-2027 - FALL TERM', 'White', NULL, 'F', NULL, 'History', NULL, 'R', 'Class of 2030: Attend the "Gearing Up For Your Future" Orientation Session', '646842', 'EVENT', '08/30/2026 08:00 AM', '08/30/2026 04:15 PM', 'Level 1', 'Communication', NULL, 'student_activity.xlsx', 29),
    ('Jaclyn', 'Stewart', 'StewartJ@moravian.edu', '277555', '03/20/2026 12:29 PM', 'Junior', NULL, NULL, '2025-2026 - FALL TERM', 'Race and Ethnicity unknown', NULL, 'F', NULL, 'Historical Studies', NULL, 'C', 'Talk with a Moravian student or alumni who has traveled abroad', '615385', 'TASK', '03/20/2026 12:00 AM', '03/20/2026 11:59 PM', 'Level 1', 'Equity & Inclusion; Teamwork', 'March into Elevate 2026', 'student_activity.xlsx', 30),
    ('Ashley', 'Williams', 'WilliamsA@moravian.edu', '026545', '04/13/2026 02:13 PM', 'Junior', NULL, 'Jennifer Bard', '2024-2025 - FALL TERM', 'White', NULL, 'F', 'Zeta Tau Alpha Sorority', 'History', 'Political Science', 'R', 'Class of 2028: Attend Halfway Hype!', '638482', 'EVENT', '04/13/2026 01:55 PM', '04/13/2026 04:10 PM', 'Level 1', 'Career & Self-Development', 'Campus Events; Second-Year Student', 'student_activity.xlsx', 31),
    ('Ben', 'Williams', 'WilliamsB@moravian.edu', '288555', '08/30/2026 02:43 PM', 'Freshman', 'Men''s Indoor Track; Men''s Outdoor Track', NULL, '2026-2027 - FALL TERM', 'Race and Ethnicity unknown', NULL, 'M', NULL, 'Accounting', NULL, 'R', 'Class of 2030: Attend the "Gearing Up For Your Future" Orientation Session', '646842', 'EVENT', '08/30/2026 08:00 AM', '08/30/2026 04:15 PM', 'Level 1', 'Communication', NULL, 'student_activity.xlsx', 32),
    ('Tamara', 'Williams', 'WilliamsT@moravian.edu', '755565', '08/30/2026 03:14 PM', 'Freshman', NULL, NULL, '2026-2027 - FALL TERM', 'Black or African American', NULL, 'F', NULL, 'Accounting', NULL, 'R', 'Class of 2030: Attend the "Gearing Up For Your Future" Orientation Session', '646842', 'EVENT', '08/30/2026 08:00 AM', '08/30/2026 04:15 PM', 'Level 1', 'Communication', NULL, 'student_activity.xlsx', 33);
