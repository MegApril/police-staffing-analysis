-- 2023 Data Cleaning
-- This query cleans string columns, corrects data type issues, combines service time, and puts the analysis in pacific time.

CREATE OR REPLACE TABLE spd_west.2023_clean AS
SELECT
  cad_event_number,

  -- Pacific local time
  MIN(
    PARSE_DATETIME(
      '%m/%d/%Y %I:%M:%S %p',
      cad_event_original_time_queued
    )
  ) AS pacific_event_datetime,

  -- Original fields
  MIN(priority) AS priority,
  ANY_VALUE(final_call_type) AS final_call_type,
  ANY_VALUE(call_type_indicator) AS call_type_indicator,
  ANY_VALUE(dispatch_beat) AS dispatch_beat,
  ANY_VALUE(dispatch_sector) AS dispatch_sector,
  MAX(count_of_officers) AS count_of_officers,

  -- Clean and compute service time
  COALESCE(
    MAX(
      SAFE_CAST(
        NULLIF(
          REGEXP_REPLACE(TRIM(spd_call_sign_total_service_time_in_seconds), r',', ''), ''
        ) AS INT64
      )
    ),
    SUM(
      SAFE_CAST(
        NULLIF(
          REGEXP_REPLACE(TRIM(call_sign_total_service_time_in_seconds), r',', '') ,''
        ) AS INT64
      )
    )
  ) AS final_service_seconds,

  -- Cleaned string fields
  UPPER(
    TRIM(
      REGEXP_REPLACE(
        REGEXP_REPLACE(ANY_VALUE(final_call_type), r'[^A-Z0-9]', ' '),
        r'\s+', ' '
      )
    )
  ) AS final_call_type_key,

  UPPER(
    TRIM(
      REGEXP_REPLACE(
        REGEXP_REPLACE(ANY_VALUE(call_type_indicator), r'[^A-Z0-9]', ' '),
        r'\s+', ' '
      )
    )
  ) AS call_type_indicator_key,

  UPPER(
    TRIM(
      REGEXP_REPLACE(
        REGEXP_REPLACE(ANY_VALUE(dispatch_sector), r'[^A-Z0-9]', ' '),
        r'\s+', ' '
      )
    )
  ) AS dispatch_sector_key,

  UPPER(
    TRIM(
      REGEXP_REPLACE(
        REGEXP_REPLACE(ANY_VALUE(dispatch_beat), r'[^A-Z0-9]', ' '),
        r'\s+', ' '
      )
    )
  ) AS dispatch_beat_key

FROM spd_west.2023
GROUP BY cad_event_number;

-- Cleaning Call Type Mapping

CREATE OR REPLACE TABLE spd_west.call_type_mapping_clean AS
SELECT
  final_call_type,
  workload_type,

  UPPER(
    TRIM(
      REGEXP_REPLACE(
        REGEXP_REPLACE(final_call_type, r'[^A-Z0-9]', ' '), r'\s+', ' '
      )
    )
  ) AS final_call_type_key

FROM spd_west.call_type_mapping;

-- Validation 1.0 - Final Call Types Match
-- 1.0 and 1.1 should return the same number of records.

SELECT
  c.final_call_type,
  COUNT(*) AS events
FROM spd_west.2023_clean c
LEFT JOIN spd_west.call_type_mapping_clean m
  ON c.final_call_type_key = m.final_call_type_key
WHERE m.final_call_type_key IS NULL
GROUP BY c.final_call_type
ORDER BY events DESC;

-- Validation 1.1 - Final Call Types Match

SELECT COUNT(*)
FROM spd_west.2023_clean c
JOIN spd_west.call_type_mapping_clean m
  ON c.final_call_type_key = m.final_call_type_key;

-- Validation 2.0 - Distinct CAD numbers and Cleaned Events
-- Distinct CAD numbers and Cleaned events should match.

SELECT 
  COUNT(*) AS raw_rows,
  COUNT(DISTINCT cad_event_number) AS distinct_events
FROM spd_west.2023;

-- Validation 2.1 - Distinct CAD numbers and Cleaned Events

SELECT COUNT(*) AS clean_rows
FROM spd_west.2023_clean;

-- Validation 3.0 - Null Service Time
-- Verify no record has NULL service time.

SELECT COUNT(*) AS null_service_time_events
FROM spd_west.2023_clean
WHERE final_service_seconds IS NULL;

-- Validation 4.0 - Pacific DATETIME NULL
-- Verify no record has NULL pacific time, which would indicate timeezone transformation issues.

SELECT COUNT(*) 
FROM spd_west.2023_clean
WHERE pacific_event_datetime IS NULL;

-- Validation 4.1 - Hour Distribution Checks
-- This should theoretically be lowest around 0300 - 0630, and peak between 1400 - 1600. This ensures there are not timezone parsing issues.

SELECT
  EXTRACT(HOUR FROM pacific_event_datetime) AS hour,
  COUNT(*) AS events
FROM spd_west.2023_clean
GROUP BY hour
ORDER BY hour;

-- Validation 5.0 - Erroneous Values - Service Time
-- Check for negatives

SELECT
  MIN(final_service_seconds) AS min_seconds,
  MAX(final_service_seconds) AS max_seconds,
  AVG(final_service_seconds) AS avg_seconds
FROM spd_west.2023_clean;

-- Validation 6.0 - Workload Logic

SELECT
  m.workload_type,
  ROUND(SUM(c.final_service_seconds)/3600,2) AS hours,
  ROUND(
    SUM(c.final_service_seconds) /
    SUM(SUM(c.final_service_seconds)) OVER(),
    3
  ) AS pct_of_total
FROM spd_west.2023_clean c
JOIN spd_west.call_type_mapping_clean m
  ON c.final_call_type_key = m.final_call_type_key
GROUP BY m.workload_type
ORDER BY hours DESC;

-- Distribution of Calls For Service
-- Count of CFS - Hourly

SELECT
  EXTRACT(HOUR FROM pacific_event_datetime) AS hour_of_day,
  COUNT(*) AS call_count
FROM spd_west.2023_clean
WHERE final_call_type != 'OFF DUTY EMPLOYMENT'
GROUP BY hour_of_day
ORDER BY hour_of_day;


-- Count of CFS - Day of Week

SELECT
  FORMAT_TIMESTAMP('%A', pacific_event_datetime) AS day_of_week,
  EXTRACT(DAYOFWEEK FROM pacific_event_datetime) AS day_number,
  COUNT(*) AS call_count
FROM spd_west.2023_clean
WHERE final_call_type != 'OFF DUTY EMPLOYMENT'
GROUP BY day_of_week, day_number
ORDER BY day_number;

-- Average Time Per CFS - Day of Week

SELECT
  EXTRACT(DAYOFWEEK FROM pacific_event_datetime) AS day_number,
  FORMAT_TIMESTAMP('%A', pacific_event_datetime) AS day_of_week,
  SUM(final_service_seconds)/3600 AS total_service_hours,
  AVG(final_service_seconds)/60 AS avg_minutes_per_call
FROM spd_west.2023_clean
WHERE final_call_type != 'OFF DUTY EMPLOYMENT'
GROUP BY day_number, day_of_week
ORDER BY day_number;

-- Count of CFS - Monthly

SELECT
  EXTRACT(MONTH FROM pacific_event_datetime) AS month_number,
  FORMAT_TIMESTAMP('%B', pacific_event_datetime) AS month_name,
  COUNT(*) AS call_count
FROM spd_west.2023_clean
WHERE final_call_type != 'OFF DUTY EMPLOYMENT'
GROUP BY month_number, month_name
ORDER BY month_number;

-- Time Consumed By Department for CFS
-- Total Time Spent On Calls by Month

SELECT
  FORMAT_DATE('%Y-%m', DATE(pacific_event_datetime)) AS year_month,
  COUNT(*) AS total_calls,
  SUM(final_service_seconds) / 3600 AS total_workload_hours,
  AVG(final_service_seconds) / 60 AS avg_minutes_per_call
FROM `police-staffing-spd-west.spd_west.2023_clean`
WHERE 
  final_service_seconds IS NOT NULL AND
  final_call_type_key != 'OFF DUTY EMPLOYMENT'
GROUP BY year_month
ORDER BY year_month;

-- Quantiles

SELECT
  MIN(final_service_seconds) / 60 AS min_minutes,
  MAX(final_service_seconds) / 60 AS max_minutes,
  AVG(final_service_seconds) / 60 AS mean_minutes,

  APPROX_QUANTILES(final_service_seconds, 100)[OFFSET(25)] / 60 AS p25_minutes,
  APPROX_QUANTILES(final_service_seconds, 100)[OFFSET(50)] / 60 AS median_minutes,
  APPROX_QUANTILES(final_service_seconds, 100)[OFFSET(75)] / 60 AS p75_minutes,
  APPROX_QUANTILES(final_service_seconds, 100)[OFFSET(95)] / 60 AS p95_minutes

FROM `police-staffing-spd-west.spd_west.2023_clean`
WHERE final_service_seconds IS NOT NULL
  AND final_call_type != 'TIME OFF EMPLOYMENT';

-- What percentage of labor is spent on the top 10% of calls?

WITH ranked AS (
  SELECT
    final_service_seconds,
    NTILE(10) OVER (ORDER BY final_service_seconds) AS decile
  FROM `police-staffing-spd-west.spd_west.2023_clean`
  WHERE final_service_seconds IS NOT NULL
    AND final_call_type != 'TIME OFF EMPLOYMENT'
)

SELECT
  SUM(CASE WHEN decile = 10 THEN final_service_seconds ELSE 0 END)
    / SUM(final_service_seconds) AS top_10_percent_share
FROM ranked;

-- Proactive vs. Reactive vs. Organizational Workload Only
-- Make sure total hours from each workload category matches total workload hours when grouped by month in the following query (workload type by month) if running both.

SELECT
  CASE
    WHEN m.workload_type = 'Organizational / Out-of-Service Workload' THEN 'Organizational'
    WHEN c.call_type_indicator_key = 'DISPATCH' THEN 'Reactive'
    WHEN c.call_type_indicator_key = 'ONVIEW' THEN 'Proactive'
    ELSE 'Uncategorized'
  END AS workload_category,
  
  COUNT(*) AS total_calls,
  SUM(c.final_service_seconds) / 3600 AS total_hours

FROM `spd_west.2023_clean` c
LEFT JOIN `spd_west.call_type_mapping_clean` m
  ON c.final_call_type_key = m.final_call_type_key

WHERE c.final_call_type_key != 'OFF DUTY EMPLOYMENT'

GROUP BY workload_category
ORDER BY total_calls DESC;

-- Proactive vs. Reactive vs. Organizational Workload by Month

SELECT
  FORMAT_TIMESTAMP('%Y-%m', c.pacific_event_datetime) AS year_month,

  CASE
    WHEN m.workload_type = 'Organizational / Out-of-Service Workload' THEN 'Organizational'
    WHEN c.call_type_indicator_key = 'DISPATCH' THEN 'Reactive'
    WHEN c.call_type_indicator_key = 'ONVIEW' THEN 'Proactive'
    ELSE 'Uncategorized'
  END AS workload_category,

  SUM(c.final_service_seconds) / 3600 AS total_hours

FROM `police-staffing-spd-west.spd_west.2023_clean` c
LEFT JOIN `police-staffing-spd-west.spd_west.call_type_mapping_clean` m
  ON c.final_call_type_key = m.final_call_type_key

WHERE c.final_call_type_key != 'OFF DUTY EMPLOYMENT'

GROUP BY year_month, workload_category
ORDER BY year_month, workload_category;

-- Proactive vs. Reactive vs. Organizational Workload - Top 5 Call Types

-- First, remove all mapped organizational workload items. Then categorize the rest of calls based on dispatch or onview from CAD data.
WITH categorized_calls AS (
  SELECT
    CASE
      WHEN m.workload_type = 'Organizational / Out-of-Service Workload' THEN 'Organizational'
      WHEN c.call_type_indicator_key = 'DISPATCH' THEN 'Reactive'
      WHEN c.call_type_indicator_key = 'ONVIEW' THEN 'Proactive'
      ELSE 'Uncategorized'
    END AS workload_category,

    c.final_call_type_key,
    c.final_service_seconds

  FROM `spd_west.2023_clean` c
  LEFT JOIN `spd_west.call_type_mapping_clean` m
    ON c.final_call_type_key = m.final_call_type_key

  WHERE c.final_call_type_key != 'OFF DUTY EMPLOYMENT'
),

-- Top call type in each workload category 
aggregated AS (
  SELECT
    workload_category,
    final_call_type_key,
    COUNT(*) AS total_calls,
    SUM(final_service_seconds) / 3600 AS total_hours
  FROM categorized_calls
  GROUP BY workload_category, final_call_type_key
),

ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY workload_category
      ORDER BY total_calls DESC
    ) AS rank_within_category
  FROM aggregated
)

SELECT
  workload_category,
  final_call_type_key,
  total_calls,
  total_hours
FROM ranked
WHERE rank_within_category <= 5
ORDER BY workload_category, total_calls DESC;
