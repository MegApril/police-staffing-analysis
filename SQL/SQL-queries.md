# SQL Queries
## Distribution of Calls For Service

### Address duplicates for cad events
```SQL
SELECT
  cad_event_number,
    COUNT(*) AS record_count
FROM `police-staffing-spd-west.spd_west.2023`
GROUP BY cad_event_number
HAVING COUNT(*) > 1
ORDER BY record_count DESC;
```

### Create table with unique cad event times and earliest timestamp.
```SQL
WITH calls AS (
  SELECT
    cad_event_number,
    MIN(cad_event_original_time_queued) AS event_time
  FROM `police-staffing-spd-west.spd_west.2023`
  GROUP BY cad_event_number
)

SELECT *
FROM calls;
```

### Create table with cleaned data types and pacific datetime
```SQL
CREATE OR REPLACE TABLE
  `spd_west.2023_events_timestamped` AS
SELECT
  cad_event_number,
  event_time,

  -- parsed timestamp
  TIMESTAMP(
    PARSE_DATETIME(
      '%m/%d/%Y %I:%M:%S %p',
      event_time
    ),
    'America/Los_Angeles'
  ) AS event_timestamp

FROM `spd_west.2023_events_times`
WHERE event_time IS NOT NULL;
```

### Number of calls grouped by hour
``` SQL
SELECT
  EXTRACT(
    HOUR FROM DATETIME(event_timestamp, 'America/Los_Angeles')
  ) AS hour_of_day,
  COUNT(*) AS call_count
FROM `spd_west.2023_events_timestamped`
GROUP BY hour_of_day
ORDER BY hour_of_day;
```

### Number of calls grouped by day of the week
```SQL
SELECT
  EXTRACT(
    DAYOFWEEK FROM DATETIME(event_timestamp, 'America/Los_Angeles')
  ) AS day_num,
  FORMAT_DATETIME(
    '%A',
    DATETIME(event_timestamp, 'America/Los_Angeles')
  ) AS day_name,
  COUNT(*) AS call_count
FROM `spd_west.2023_events_timestamped`
GROUP BY day_num, day_name
ORDER BY day_num;
```

### Number of calls grouped by Month
```SQL
SELECT
  EXTRACT(
    MONTH FROM DATETIME(event_timestamp, 'America/Los_Angeles')
  ) AS month_num,
  FORMAT_DATETIME(
    '%B',
    DATETIME(event_timestamp, 'America/Los_Angeles')
  ) AS month_name,
  COUNT(*) AS call_count
FROM `spd_west.2023_events_timestamped`
GROUP BY month_num, month_name
ORDER BY month_num;
```
## Estimated Time Consumed By Department
My objective here is to group calls by the total department time spent on the individual CAD event using the CAD event ID, and total service time. Calls will then be categorized based on how much total time the department allocated to the CAD event number in the following categories.
1. 0-1800 seconds (30 minutes),
2. 1800-3600 seconds (30 minutes - 1 hour),
3. 3600-7200 seconds (1-2 hours),
4. 7200+ seconds (2+ hours)
With all calls categorized into times, we can then determine the top call types for each category to link nature of calls to actual time spent.

### Base Table and Data Cleaning
-- Create calls base table with unique cad events, total service time and the final call type. 
-- Adressing service time data type issue, trimming white space, stripping commas, while retaining unique CAD event.
```SQL
CREATE OR REPLACE TABLE `police-staffing-spd-west.spd_west.2023_calls_base` AS

WITH cleaned AS (
  SELECT
    cad_event_number,
    final_call_type,
    priority,
    call_type_indicator
    dispatch_beat,
    dispatch_sector,
    count_of_officers,

    -- parse original queued time as Pacific timestamp
    PARSE_TIMESTAMP(
      '%m/%d/%Y %I:%M:%S %p',
      cad_event_original_time_queued,
      'America/Los_Angeles'
    ) AS cad_event_original_timestamp,

    SAFE_CAST(
      NULLIF(
        REGEXP_REPLACE(
          TRIM(spd_call_sign_total_service_time_in_seconds),
          r',',
          ''
        ),
        ''
      ) AS INT64
    ) AS spd_total_service_seconds,

    SAFE_CAST(
      NULLIF(
        REGEXP_REPLACE(
          TRIM(call_sign_total_service_time_in_seconds),
          r',',
          ''
        ),
        ''
      ) AS INT64
    ) AS call_sign_service_seconds

  FROM `spd_west.2023`
)

SELECT
  cad_event_number,
  MIN(priority) AS priority,
  ANY_VALUE(final_call_type) AS final_call_type,
  ANY_VALUE(cad_event_original_timestamp) AS cad_event_original_timestamp,
  ANY_VALUE(call_type_indicator) AS call_type_indicator,
  ANY_VALUE(dispatch_beat) AS dispatch_beat,
  ANY_VALUE(dispatch_sector) AS dispatch_sector,
  MAX(count_of_officers) AS count_of_officers,

  COALESCE(
    MAX(spd_total_service_seconds),
    SUM(call_sign_service_seconds)
  ) AS final_service_seconds

FROM cleaned
GROUP BY cad_event_number;
```

### Validating the data cleaning worked
```SQL
SELECT
  COUNT(*) AS total_calls,
  COUNT(final_service_seconds) AS parsed_calls,
  COUNT(*) - COUNT(final_service_seconds) AS still_null,
  MIN(final_service_seconds) AS min_sec,
  MAX(final_service_seconds) AS max_sec
FROM `spd_west.2023_calls_base`;
```
### Creating call buckets
```SQL
CREATE OR REPLACE TABLE `spd_west.2023_calls_buckets` AS
SELECT
  cad_event_number,
    DATETIME(cad_event_original_timestamp, 'America/Los_Angeles')
  AS cad_event_original_pacific,
  cad_event_original_timestamp,
  final_call_type,
  final_service_seconds,

  CASE
    WHEN final_service_seconds < 1800 THEN '0–30 min'
    WHEN final_service_seconds < 3600 THEN '30–60 min'
    WHEN final_service_seconds < 10800 THEN '1–3 hours'
    WHEN final_service_seconds < 21600 THEN '3-6 hours'
    ELSE '6+ hours'
  END AS duration_bucket

FROM `spd_west.2023_calls_base`
WHERE final_service_seconds >= 0;
```
### Number of calls per time bucket, and total time spent in each bucket by month.
```SQL
SELECT
  FORMAT_DATE('%Y-%m', DATE(cad_event_original_pacific)) AS year_month,
  duration_bucket,
  COUNT(*) AS call_count,
  SUM(final_service_seconds) AS total_service_seconds
FROM `spd_west.2023_calls_buckets`
GROUP BY year_month, duration_bucket
ORDER BY year_month, duration_bucket;
```
### Total time spent on calls by month
```SQL
SELECT
  FORMAT_DATE('%Y-%m', DATE(cad_event_original_pacific)) AS year_month,
  COUNT(*) AS total_calls,
  SUM(final_service_seconds) AS total_service_seconds
FROM `spd_west.2023_calls_buckets`
GROUP BY year_month
ORDER BY year_month;
```
### Total Hours Worked distributed by time of day
```SQL
SELECT
  EXTRACT(HOUR FROM DATETIME(cad_event_original_timestamp, "America/Los_Angeles")) AS hour_of_day,
  COUNT(*) AS total_calls,
  SUM(final_service_seconds) / 3600 AS total_hours
FROM `police-staffing-spd-west.spd_west.2023_calls_base`
GROUP BY hour_of_day
ORDER BY hour_of_day;
```
### Quantiles
```SQL
SELECT
  APPROX_QUANTILES(final_service_seconds, 5) AS quintiles
FROM `spd_west.2023_calls_buckets`;
```
|Quintiles| Value in Seconds | Description|
|--|--|--|
|Min|0| The minimum time for a call iss 0 seconds|
|25th perecentile | 650| 25% of calls are under 11 minutes  |
|Median|1,877|The median of all calls is approx 31 min |
|75th percentile|3,886| 75% of calls are under 65 minutes|
|95th percentile|9,049| 95% of calls are under 151 minutes (about 2.5 hours)|
|Max|1,381,795| The maximum is driving up the average of all calls with a whopping 383 hours or 16 days of labor|

### Average time per bucket
```SQL
SELECT
  duration_bucket,
  COUNT(*) AS calls,
  ROUND(AVG(final_service_seconds)/60,1) AS avg_minutes
FROM `spd_west.2023_calls_buckets`
GROUP BY duration_bucket;
```
| Row|	duration_bucket|	calls	|avg_minutes|
|--|--|--|--|
|1	|0–30 min|	37994	|11.7|
|2	|30–60 min	|18555	|43.6|
|3|	1–3 hours|	25094	|105.9|
|4	|3-6 hours|	9556	|249.0|
|5	|6+ hours|	6540	|772.7|

### Top 50 Calls
```SQL
SELECT
  cad_event_number,
  final_call_type,
  cad_event_original_pacific,
  final_service_seconds/3600 AS hours
FROM `spd_west.2023_calls_buckets`
ORDER BY final_service_seconds DESC
LIMIT 50;
```
### What percentage of labor is spent on the top 10% of calls?
-- Break calls into 10 equal categories (NILE) using window functions.
```SQL
WITH ranked AS (
  SELECT
    final_service_seconds,
    NTILE(10) OVER (ORDER BY final_service_seconds DESC) AS decile
  FROM `spd_west.2023_calls_buckets`
)

SELECT
  ROUND(
    SUM(CASE WHEN decile = 1 THEN final_service_seconds ELSE 0 END)
    /
    SUM(final_service_seconds),
    4
  ) AS top_10_percent_labor_share
FROM ranked;
```
**53% of labor is consumed by the top 10% of calls.**

### Onview vs. Dispatch
```SQL
WITH monthly AS (
  SELECT
    FORMAT_TIMESTAMP(
      '%Y-%m',
      cad_event_original_timestamp,
      'America/Los_Angeles'
    ) AS year_month,
    call_type_indicator,
    final_service_seconds
  FROM `police-staffing-spd-west.spd_west.2023_calls_base`
)

SELECT
  year_month,
  call_type_indicator,
  COUNT(*) AS total_events,
  SUM(final_service_seconds) AS total_service_seconds,
  ROUND(SUM(final_service_seconds)/3600, 2) AS total_service_hours
FROM monthly
GROUP BY year_month, call_type_indicator
ORDER BY year_month, call_type_indicator;
```
### Determining if admin duties associated with cad events are logged with the same cad event number, or as a different cad event number.
They are logged under a different cad event number
```SQL
WITH multi_row_events AS (
  SELECT
    cad_event_number
  FROM `spd_west.2023`
  GROUP BY cad_event_number
  HAVING COUNT(*) > 1
)

SELECT
  cad_event_number,
  final_call_type,
  priority,
  call_type_indicator,
  spd_call_sign_total_service_time_in_seconds,
  call_sign_total_service_time_in_seconds
FROM `spd_west.2023`
WHERE cad_event_number IN (
  SELECT cad_event_number FROM multi_row_events
)
ORDER BY cad_event_number;
```
### Creating policing type based on onview, dispatch, and non-patrol work.
-- Created mapping csv, joined with calls_base table to show policing type
-- Determining hours spent in each category
```SQL
SELECT 
  policing_type, 
  COUNT(*) AS event_count,
  ROUND(SUM(final_service_seconds)/3600, 2) AS total_hours
FROM (
  SELECT
    c.final_service_seconds, 
    c.call_type_indicator, 
    c.final_call_type, 
    c.cad_event_number,
    CASE
      WHEN m.admin_tag = 'Non-Patrol' THEN 'Non-Patrol'
      WHEN c.call_type_indicator = 'ONVIEW' THEN 'Onview'
      WHEN c.call_type_indicator = 'DISPATCH' THEN 'Dispatch'
      ELSE 'Unknown'
    END AS policing_type
  FROM `police-staffing-spd-west.spd_west.2023_calls_base` c
  LEFT JOIN `police-staffing-spd-west.spd_west.call_type_mapping_clean` m
    ON c.final_call_type = m.final_call_type
)
GROUP BY policing_type
ORDER BY total_hours DESC;
```
### Nature of Calls - Top 25 by Call Counts
```SQL
SELECT
  final_call_type,
  COUNT(*) AS total_calls,
  SUM(final_service_seconds)/3600 AS total_service_hours,
FROM `police-staffing-spd-west.spd_west.2023_calls_base`
WHERE final_call_type IS NOT NULL
GROUP BY final_call_type
ORDER BY total_calls DESC
LIMIT 25;
```
### Nature of Calls - Top 25 by Aggregated Hours per Final Call Typee category
```SQL
SELECT
  final_call_type,
  COUNT(*) AS total_calls,
  SUM(final_service_seconds) AS total_service_seconds,
  SUM(final_service_seconds)/3600 AS total_service_hours,
  AVG(final_service_seconds) AS avg_service_seconds
FROM `police-staffing-spd-west.spd_west.2023_calls_base`
WHERE final_call_type IS NOT NULL
  AND final_service_seconds IS NOT NULL
GROUP BY final_call_type
ORDER BY total_service_seconds DESC
LIMIT 25;
```
