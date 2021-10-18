-- daily_activity: none
SELECT 
    *,
    COUNT(*)
FROM
    daily_activity
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

-- daily_calories: none
SELECT 
    *,
    COUNT(*)
FROM
    daily_calories
GROUP BY
    id,
    activity_day,
    calories
HAVING
    COUNT(*) > 1
;

-- daily_intensities: none.
SELECT 
    *,
    COUNT(*)
FROM
    daily_intensities
GROUP BY
    id,
    activity_day,
    sedentary_minutes,
    lightly_active_minutes,
    fairly_active_minutes,
    very_active_minutes,
    sedentary_active_distance,
    light_active_distance,
    moderately_active_distance,
    very_active_distance
HAVING
    COUNT(*) > 1
;

-- daily_sleep: 3 duplicate entries found.
SELECT 
    *,
    COUNT(*)
FROM
    daily_sleep
GROUP BY
    id,
    sleep_day,
    total_minutes_asleep,
    total_sleep_records,
    total_time_in_bed
HAVING
    COUNT(*) > 1
;

-- daily_steps: none
SELECT 
    id,
    activity_day,
    total_steps,
    COUNT(*)
FROM
    daily_steps
GROUP BY
    id,
    activity_day,
    total_steps
HAVING
    COUNT(*) > 1
;

-- hourly_calories: none
SELECT 
    id,
    activity_hour,
    calories,
    COUNT(*)
FROM
    hourly_calories
GROUP BY
    id,
    activity_hour,
    calories
HAVING
    COUNT(*) > 1
;

-- hourly_intensities: none
SELECT 
    *,
    COUNT(*)
FROM
    hourly_intensities
GROUP BY
    id,
    activity_hour,
    total_intensity,
    average_intensity
HAVING
    COUNT(*) > 1
;

-- hourly_steps: none
SELECT 
    *,
    COUNT(*)
FROM
    hourly_steps
GROUP BY
    id,
    activity_hour,
    total_steps
HAVING
    COUNT(*) > 1
;

-- minute_calories_narrow: none
SELECT 
    *,
    COUNT(*)
FROM
    minute_calories_narrow
GROUP BY
    id,
    activity_minute,
    calories
HAVING
    COUNT(*) > 1
;

-- minute_calories_wide: none
SELECT 
    *,
    COUNT(*)
FROM
    minute_calories_wide
GROUP BY
    id,
    activity_hour,
    calories_00,
    calories_01,
    calories_02,
    calories_03,
    calories_04,
    calories_05,
    calories_06,
    calories_07,
    calories_08,
    calories_09,
    calories_10,
    calories_11,
    calories_12,
    calories_13,
    calories_14,
    calories_15,
    calories_16,
    calories_17,
    calories_18,
    calories_19,
    calories_20,
    calories_21,
    calories_22,
    calories_23,
    calories_24,
    calories_25,
    calories_26,
    calories_27,
    calories_28,
    calories_29,
    calories_30,
    calories_31,
    calories_32,
    calories_33,
    calories_34,
    calories_35,
    calories_36,
    calories_37,
    calories_38,
    calories_39,
    calories_40,
    calories_41,
    calories_42,
    calories_43,
    calories_44,
    calories_45,
    calories_46,
    calories_47,
    calories_48,
    calories_49,
    calories_50,
    calories_51,
    calories_52,
    calories_53,
    calories_54,
    calories_55,
    calories_56,
    calories_57,
    calories_58,
    calories_59
HAVING
    COUNT(*) > 1
;

-- minute_intensities_narrow: none
SELECT 
    *,
    COUNT(*)
FROM
    minute_intensities_narrow
GROUP BY
    id,
    activity_minute,
    intensity
HAVING
    COUNT(*) > 1
;

-- minute_intensities_wide: none
SELECT 
    *,
    COUNT(*)
FROM
    minute_intensities_wide
GROUP BY
    id,
    activity_hour,
    intensity_00,
    intensity_01,
    intensity_02,
    intensity_03,
    intensity_04,
    intensity_05,
    intensity_06,
    intensity_07,
    intensity_08,
    intensity_09,
    intensity_10,
    intensity_11,
    intensity_12,
    intensity_13,
    intensity_14,
    intensity_15,
    intensity_16,
    intensity_17,
    intensity_18,
    intensity_19,
    intensity_20,
    intensity_21,
    intensity_22,
    intensity_23,
    intensity_24,
    intensity_25,
    intensity_26,
    intensity_27,
    intensity_28,
    intensity_29,
    intensity_30,
    intensity_31,
    intensity_32,
    intensity_33,
    intensity_34,
    intensity_35,
    intensity_36,
    intensity_37,
    intensity_38,
    intensity_39,
    intensity_40,
    intensity_41,
    intensity_42,
    intensity_43,
    intensity_44,
    intensity_45,
    intensity_46,
    intensity_47,
    intensity_48,
    intensity_49,
    intensity_50,
    intensity_51,
    intensity_52,
    intensity_53,
    intensity_54,
    intensity_55,
    intensity_56,
    intensity_57,
    intensity_58,
    intensity_59
HAVING
    COUNT(*) > 1
;


-- minute_steps_narrow: none
SELECT 
    *,
    COUNT(*)
FROM
    minute_steps_narrow
GROUP BY
    id,
    activity_minute,
    steps
HAVING
    COUNT(*) > 1
;

-- minute_steps_wide: none
SELECT 
    *,
    COUNT(*)
FROM
    minute_steps_wide
GROUP BY
    id,
    activity_hour,
    steps_00,
    steps_01,
    steps_02,
    steps_03,
    steps_04,
    steps_05,
    steps_06,
    steps_07,
    steps_08,
    steps_09,
    steps_10,
    steps_11,
    steps_12,
    steps_13,
    steps_14,
    steps_15,
    steps_16,
    steps_17,
    steps_18,
    steps_19,
    steps_20,
    steps_21,
    steps_22,
    steps_23,
    steps_24,
    steps_25,
    steps_26,
    steps_27,
    steps_28,
    steps_29,
    steps_30,
    steps_31,
    steps_32,
    steps_33,
    steps_34,
    steps_35,
    steps_36,
    steps_37,
    steps_38,
    steps_39,
    steps_40,
    steps_41,
    steps_42,
    steps_43,
    steps_44,
    steps_45,
    steps_46,
    steps_47,
    steps_48,
    steps_49,
    steps_50,
    steps_51,
    steps_52,
    steps_53,
    steps_54,
    steps_55,
    steps_56,
    steps_57,
    steps_58,
    steps_59
HAVING
    COUNT(*) > 1
;


-- minute_mets_narrow: none
SELECT 
    *,
    COUNT(*)
FROM
    minute_mets_narrow
GROUP BY
    id,
    activity_minute,
    mets
HAVING
    COUNT(*) > 1
;

-- minute_sleep: Looks like every entry for id '4702921684' has a duplicate.
SELECT 
    *,
    COUNT(*)
FROM
    minute_sleep
GROUP BY
    id,
    date,
    value,
    log_id
HAVING
    COUNT(*) > 1
;

        -- Checking how many ids are affected.
        SELECT
            DISTINCT ON (id) id,
            date,
            value,
            log_id,
            COUNT(*)
        FROM
            minute_sleep
        GROUP BY
            id,
            date,
            value,
            log_id
        HAVING
            COUNT(*) > 1
        ;

-- seconds_heartrate: none.
SELECT 
    *,
    COUNT(*)
FROM
    seconds_heartrate
GROUP BY
    id,
    time,
    value
HAVING
    COUNT(*) > 1
;

-- weight_log_info: none.
SELECT 
    *,
    COUNT(*)
FROM
    weight_log_info
GROUP BY
    id,
    date,
    weight_kg,
    weight_lb,
    fat,
    bmi,
    manual_report,
    log_id
HAVING
    COUNT(*) > 1
;