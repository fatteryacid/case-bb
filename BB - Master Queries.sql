--------------------------------------------------
---------- CASE STUDY 2: Bellabeat ---------------
---------- Presented by Tyler Tran ---------------
--------------------------------------------------

-- The following queries are written for Postgres 13

-------------------------------
-- Step 1: Cleaning datasets --
-------------------------------

-- Checking for null values
SELECT * 
FROM table_name
WHERE NOT (table_name IS NOT NULL);
    -- RESULT: 65 nulls in 'fat' column. 



--Checking for duplicates
SELECT 
    *,
    COUNT(*)
FROM
    daily_activity -- Basic query structure. Modified for other tables.
GROUP BY
    id,
    activity_date,
    total_steps,
    total_distance,
    tracker_distance,
    logged_activities_distance,
    sedentary_minutes,
    lightly_active_minutes,
    fairly_active_minutes,
    very_active_minutes,
    sedentary_active_distance,
    light_active_distance,
    moderately_active_distance,
    very_active_distance,
    calories
HAVING
    COUNT(*) > 1
;
    -- RESULT: daily_sleep and minute_sleep have duplicates.



-- Created cleaned version of affected tables --
CREATE TABLE 
    cleaned_daily_sleep AS (
        SELECT DISTINCT
            *
        FROM
            daily_sleep -- Had 3 duplicates
    );

CREATE TABLE 
    cleaned_minute_sleep AS (
        SELECT DISTINCT
            *
        FROM
            minute_sleep -- Had duplicates for specific ID.
    );



-- Checking for ID data inconsistencies --
SELECT
    DISTINCT ON (id) id,
    LENGTH(id) AS char_count
FROM
    daily_activity -- For every table.
;
    -- RESULT: All id columns match
    -- PATTERN: All sleep tables contain 24 'unique' ids. 
    --          Seconds heartrate table contains 14 unique ids.
    --          Weight log info table contains 8 unique ids.



-- Standardizing column names across activity minutes and distance
-- Minute table
CREATE TABLE daily_active_minute AS (
    SELECT
        id,
        activity_day,
        sedentary_minutes,
        lightly_active_minutes AS light_active_minutes, 
        fairly_active_minutes AS moderately_active_minutes,
        very_active_minutes,
        (1440 -  -- Checking for minutes not recorded during the day.
            (
                sedentary_minutes +
                lightly_active_minutes +
                fairly_active_minutes +
                very_active_minutes
            )
        ) AS lost_minutes,
        (
            sedentary_minutes +
            lightly_active_minutes +
            fairly_active_minutes +
            very_active_minutes  
        ) AS total_active_minutes
    FROM
        daily_intensities
)
;

-- Distance table
CREATE TABLE daily_active_distance AS (
    SELECT
        id,
        activity_day,
        sedentary_active_distance AS sedentary_distance,
        light_active_distance,
        moderately_active_distance,
        very_active_distance,
        (
            sedentary_active_distance +
            light_active_distance +
            moderately_active_distance +
            very_active_distance
        ) AS total_active_distance
    FROM
        daily_intensities
)
;



-------------------------------
-- Step 2: Pattern checking  --
-------------------------------

-- Are any columns recurring? --
SELECT
    column_name,
    COUNT(table_name) AS instances
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = 'public'
GROUP BY
    column_name
ORDER BY
    instances DESC;
    -- RESULT: 'id' column is recurring (18 times).



-- Which tables have an 'id' column? --
SELECT
    table_name,
    SUM(CASE
            WHEN column_name = 'id' THEN 1
            ELSE 0
            END
    ) AS exists
FROM INFORMATION_SCHEMA.COLUMNS
WHERE column_name = 'id'
GROUP BY table_name;
    -- RESULT: 'id' column is present in all tables.
    -- 'id' column may be used for JOINs.



-- Do all tables have a date or time column? --
SELECT
    table_name,
    SUM(CASE
            WHEN data_type IN ('timestamp with time zone', 'timestamp without time zone', 'date') THEN 1
            ELSE 0
            END
    ) AS has_date_or_time
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema='public'
GROUP BY table_name;
    -- RESULT: Every table has a time/date column.



-- Identifying time/date columns --
SELECT
    table_name,
    column_name
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE data_type IN (
    'timestamp with time zone',
    'timestamp without time zone',
    'date'
) AND table_schema = 'public';
    -- RESULT: Identified column name of every time/date column.
    -- PATTERN: Tables are split into daily/hourly/minute



-- Checking to see which time/date columns share common data types --
SELECT
    table_name,
    column_name,
    data_type
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE data_type IN (
    'timestamp with time zone',
    'timestamp without time zone',
    'date'
) AND table_schema = 'public';
    -- RESULT: day/daily columns are stored as DATE.
    --        hour/minute/seconds are stored as TIMESTAMP WITHOUT TIME ZONE.



-- Count number of columns following a general year, month, day format
WITH
    validity AS (
        SELECT (
            activity_date :: VARCHAR ~ '\d{2,4}[/-]\d{1,2}[/-]\d{1,2}' = '0'
            ) :: INT AS invalid_count,
            id
        FROM daily_activity
        )

SELECT
    SUM(invalid_count) AS total_invalid,
    COUNT(id) AS total_rows

FROM
    validity
;
    -- RESULT: All columns follow a year, month, day date format.



-- Confirming whether YYYY-MM-DD or YYYY-DD-MM
WITH date_check AS (
    SELECT
        (activity_date :: VARCHAR ~ '\d{4}[/-](0[1-9]|1[012])[/-](0[1-9]|[12][0-9]|3[01])' = '1') :: INT AS month_day,
        (activity_date :: VARCHAR ~ '\d{4}[/-](0[1-9]|[12][0-9]|3[012])[/-](0[1-9]|1[012])' = '1') :: INT AS day_month,
        activity_date
    FROM
        daily_activity
)
SELECT
    COUNT(activity_date) AS total_dates,
    SUM(month_day) AS total_month_day,
    SUM(day_month) AS total_day_month
FROM
    date_check
;
    -- RESULT: 362 rows also qualify as day_month.



-- Checking rows hit by previous query --
WITH date_check AS (
    SELECT
        (activity_date :: VARCHAR ~ '\d{4}[/-](0[1-9]|[12][0-9]|3[012])[/-](0[1-9]|1[012])' = '1') :: INT AS day_month,
        activity_date
    FROM
        daily_activity
)
SELECT
    activity_date
FROM
    date_check
WHERE day_month = 1
;
    -- RESULT: None of the dates were in day_month format.
    -- RESULT: Confirmed ALL dates are YYYY-MM-DD format.



-- The query below finds tables other than daily_activity that use day/daily data.
WITH
    total_daily_match AS (
        SELECT
            table_name,
            column_name,
            data_type,
            table_schema,
            table_name ~ 'day|daily' AS table_daily_match,
            column_name ~ 'day|daily' AS column_daily_match
        FROM
            INFORMATION_SCHEMA.COLUMNS
    )
SELECT
    table_name,
    column_name,
    data_type
FROM
    total_daily_match
WHERE
    table_daily_match = 't' AND
    column_daily_match = 't'
;
    -- RESULT: daily_calories, daily_intensities, daily_steps, and daily_sleep all use same date/time formats.



-- Query below joins together all daily-date/time formats to check whether id and date formats align across all 'daily' tables.
SELECT
    daily_activity.id,
    daily_activity.activity_date,
    daily_activity.total_distance,
    daily_activity.tracker_distance,
    daily_activity.logged_activities_distance,
    daily_steps.total_steps,
    daily_intensities.sedentary_minutes,
    daily_intensities.lightly_active_minutes,
    daily_intensities.fairly_active_minutes,
    daily_intensities.very_active_minutes,
    daily_intensities.light_active_distance AS lightly_active_distance,
    daily_intensities.moderately_active_distance,
    daily_activity.very_active_distance,
    daily_calories.calories,
    daily_sleep.total_sleep_records,
    daily_sleep.total_minutes_asleep,
    daily_sleep.total_time_in_bed
FROM
    daily_activity
    LEFT JOIN daily_calories
        ON daily_activity.id = daily_calories.id
        AND daily_activity.activity_date = daily_calories.activity_day
        AND daily_activity.calories = daily_calories.calories
    LEFT JOIN daily_intensities
        ON daily_activity.id = daily_intensities.id
        AND daily_activity.sedentary_minutes = daily_intensities.sedentary_minutes
        AND daily_activity.lightly_active_minutes = daily_intensities.lightly_active_minutes
        AND daily_activity.fairly_active_minutes = daily_intensities.fairly_active_minutes
        AND daily_activity.very_active_minutes = daily_intensities.very_active_minutes
        AND daily_activity.sedentary_active_distance = daily_intensities.sedentary_active_distance
        AND daily_activity.light_active_distance = daily_intensities.light_active_distance
        AND daily_activity.moderately_active_distance = daily_intensities.moderately_active_distance
        AND daily_activity.very_active_distance = daily_intensities.very_active_distance
    LEFT JOIN daily_sleep
        ON daily_activity.id = daily_sleep.id
        AND daily_activity.activity_date = daily_sleep.sleep_day
    LEFT JOIN daily_steps
        ON daily_activity.id = daily_steps.id
        AND daily_activity.activity_date = daily_steps.activity_day
;
    -- RESULT: JOINs success. Daily tables share the same date data-type format.



-- Determining how much of the sleep records are naps.
-- Defining naps as any sleep record where an individual wakes up on the same day.

-- Checking log_id relevance to date with one log_id
SELECT
    log_id,
    MIN(date) AS min_date,
    MAX(date) AS max_date
FROM minute_sleep
GROUP BY log_id
;
    -- RESULT: log_id is one unique sleep record from beginning to end.
    -- Still unsure to what 'value' column refers to.
    -- Will include in footnote and disregard since we do not have access to a stakeholder to ask for more questions.



-- Checking what datatype MAX() and MIN() return.
SELECT
    log_id,
    MAX(date) - MIN (date) AS test
FROM
    minute_sleep
GROUP BY log_id
LIMIT 10;
    -- RESULT: Returns as INTERVAL



-- Returns total records of naps and nap time for each user.
WITH calculated AS (
    SELECT
        id,
        log_id,
        MIN(DATE(date)) AS sleep_start,
        MAX(DATE(date)) AS sleep_end,
        MAX(date) - MIN(date) AS sleep_time
    FROM
        minute_sleep
    GROUP BY
        log_id,
        id
)
SELECT
    id,
    COUNT(log_id) AS nap_amount,
    SUM(EXTRACT(HOUR FROM sleep_time)) AS total_nap_time
FROM
    calculated
WHERE
    sleep_start = sleep_end
GROUP BY
    id
ORDER BY
    nap_amount DESC;
    -- RESULT: Few users take many habitual naps. Most users do not take many naps.



-- Creating person-level table with all relevant information.
CREATE TABLE master_summary AS (
    -- Defining 'variables' --
    WITH 
        -- First parameter --
        dow_summary AS ( 
        SELECT
            id,
            EXTRACT(DOW FROM activity_hour) AS dow_num,
            TO_CHAR(activity_hour, 'Dy') AS dow,
            CASE -- Figuring out which day of the week
                WHEN EXTRACT(DOW FROM activity_hour) IN (0, 6) THEN 'Weekend'
                WHEN EXTRACT(DOW FROM activity_hour) NOT IN (0,6) THEN 'Weekday'
                ELSE 'ERROR'
            END
                AS part_of_week,
            CASE -- Figuring out which time of day
                 -- Potential accuracy issue as there is no standard.
                WHEN EXTRACT(HOUR FROM activity_hour) BETWEEN 4 AND 11 THEN 'Morning'
                WHEN EXTRACT(HOUR FROM activity_hour) BETWEEN 12 AND 16 THEN 'Afternoon'
                WHEN EXTRACT(HOUR FROM activity_hour) BETWEEN 17 AND 20 THEN 'Evening'
                WHEN EXTRACT(HOUR FROM activity_hour) BETWEEN 21 AND 23 THEN 'Night'
                WHEN EXTRACT(HOUR FROM activity_hour) BETWEEN 0 AND 3 THEN 'Night'
                ELSE 'Error'
            END
                AS time_of_day,
            ROUND(SUM(total_intensity), 3) AS total_intensity,
            ROUND(SUM(average_intensity), 3) AS total_avg_intensity,
            ROUND(AVG(average_intensity), 3) AS avg_intensity,
            ROUND(MAX(average_intensity), 3) AS max_intensity,
            ROUND(MIN(average_intensity), 3) AS min_intensity
        FROM hourly_intensities
        GROUP BY 
            id,
            activity_hour
        ORDER BY
            id DESC
    ),

    -- Second parameter --
    intensity_deciles AS (
        SELECT
            dow_summary.part_of_week,
            dow_summary.dow,
            dow_summary.time_of_day,
            decile_sub.t_intensity_1st_decile,
            decile_sub.t_intensity_2nd_decile,
            decile_sub.t_intensity_3rd_decile,
            decile_sub.t_intensity_4th_decile,
            decile_sub.t_intensity_5th_decile,
            decile_sub.t_intensity_6th_decile,
            decile_sub.t_intensity_7th_decile,
            decile_sub.t_intensity_8th_decile,
            decile_sub.t_intensity_9th_decile
        FROM (
            SELECT
                DISTINCT ON (dow_num) dow_num,
                        ROUND(PERCENTILE_CONT(0.1) WITHIN GROUP(ORDER BY total_intensity) :: NUMERIC, 3) AS t_intensity_1st_decile,
                        ROUND(PERCENTILE_CONT(0.2) WITHIN GROUP(ORDER BY total_intensity) :: NUMERIC, 3) AS t_intensity_2nd_decile,
                        ROUND(PERCENTILE_CONT(0.3) WITHIN GROUP(ORDER BY total_intensity) :: NUMERIC, 3) AS t_intensity_3rd_decile,
                        ROUND(PERCENTILE_CONT(0.4) WITHIN GROUP(ORDER BY total_intensity) :: NUMERIC, 3) AS t_intensity_4th_decile,
                        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY total_intensity) :: NUMERIC, 3) AS t_intensity_5th_decile,
                        ROUND(PERCENTILE_CONT(0.6) WITHIN GROUP(ORDER BY total_intensity) :: NUMERIC, 3) AS t_intensity_6th_decile,
                        ROUND(PERCENTILE_CONT(0.7) WITHIN GROUP(ORDER BY total_intensity) :: NUMERIC, 3) AS t_intensity_7th_decile,
                        ROUND(PERCENTILE_CONT(0.8) WITHIN GROUP(ORDER BY total_intensity) :: NUMERIC, 3) AS t_intensity_8th_decile,
                        ROUND(PERCENTILE_CONT(0.9) WITHIN GROUP(ORDER BY total_intensity) :: NUMERIC, 3) AS t_intensity_9th_decile
            FROM
                dow_summary
            GROUP BY
                dow_num
            ) AS decile_sub,
            dow_summary -- This is necessary to reference columns
    ),

    -- Third parameter -- 
    basic_summary AS (
        SELECT
            id,
            dow_num,
            part_of_week,
            dow,
            time_of_day,
            ROUND(SUM(total_intensity), 3) AS t_t_intensity,
            ROUND(AVG(total_intensity), 3) AS avg_t_intensity,
            ROUND(SUM(total_avg_intensity), 3) AS t_t_avg_intensity,
            ROUND(AVG(total_avg_intensity), 3) AS avg_t_avg_intensity,
            ROUND(SUM(avg_intensity), 3) AS t_avg_intensity,
            ROUND(AVG(avg_intensity), 3) AS avg_avg_intensity,
            ROUND(AVG(max_intensity), 3) AS avg_max_intensity,
            ROUND(AVG(min_intensity), 3) AS avg_min_intensity
        FROM
            dow_summary
        GROUP BY
            id,
            time_of_day,
            dow,
            part_of_week,
            dow_num
    )

    -- Begin actual query -- 
    SELECT
        *
    FROM
        basic_summary
    LEFT JOIN intensity_deciles
    USING
        (
            part_of_week,
            dow,
            time_of_day
        )
    ORDER BY
        id,
        time_of_day,
        part_of_week,
        dow,
        dow_num,
        CASE
            WHEN time_of_day = 'Morning' THEN 0
            WHEN time_of_day = 'Afternoon' THEN 1
            WHEN time_of_day = 'Evening' THEN 2
            WHEN time_of_day = 'Night' THEN 3
        END
    )
;



------------------------------------------------
-- Step 3: Exporting new tables for analysis  --
------------------------------------------------

-- Export for visualization in Tableau
COPY (
    SELECT
        *
    FROM
        master_summary
)
TO
    '/Users/tylertran/Documents/Data Analyst Projects/Case Study 2 Bellabeat/Exported/master-summary.csv'
DELIMITER ','
CSV HEADER
;

COPY (
    SELECT
        *
    FROM
        daily_active_minute
)
TO
    '/Users/tylertran/Documents/Data Analyst Projects/Case Study 2 Bellabeat/Exported/daily_active_minute.csv'
DELIMITER ','
CSV HEADER
;

COPY (
    SELECT
        *
    FROM
        daily_active_distance
)
TO
    '/Users/tylertran/Documents/Data Analyst Projects/Case Study 2 Bellabeat/Exported/daily_active_distance.csv'
DELIMITER ','
CSV HEADER
;
