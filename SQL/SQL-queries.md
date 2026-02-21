# SQL Queries
## 2023 Data Cleaning
This query cleans string columns, corrects data type issues, combines service time, and puts the analysis in pacific time.
```SQL
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
          REGEXP_REPLACE(TRIM(spd_call_sign_total_service_time_in_seconds), r',', ''),
          ''
        ) AS INT64
      )
    ),
    SUM(
      SAFE_CAST(
        NULLIF(
          REGEXP_REPLACE(TRIM(call_sign_total_service_time_in_seconds), r',', ''),
          ''
        ) AS INT64
      )
    )
  ) AS final_service_seconds,

  -- Cleaned string fields
  UPPER(
    TRIM(
      REGEXP_REPLACE(
        REGEXP_REPLACE(ANY_VALUE(final_call_type), r'[^A-Z0-9]', ' '),
        r'\s+',
        ' '
      )
    )
  ) AS final_call_type_key,

  UPPER(
    TRIM(
      REGEXP_REPLACE(
        REGEXP_REPLACE(ANY_VALUE(call_type_indicator), r'[^A-Z0-9]', ' '),
        r'\s+',
        ' '
      )
    )
  ) AS call_type_indicator_key,

  UPPER(
    TRIM(
      REGEXP_REPLACE(
        REGEXP_REPLACE(ANY_VALUE(dispatch_sector), r'[^A-Z0-9]', ' '),
        r'\s+',
        ' '
      )
    )
  ) AS dispatch_sector_key,

  UPPER(
    TRIM(
      REGEXP_REPLACE(
        REGEXP_REPLACE(ANY_VALUE(dispatch_beat), r'[^A-Z0-9]', ' '),
        r'\s+',
        ' '
      )
    )
  ) AS dispatch_beat_key

FROM spd_west.2023
GROUP BY cad_event_number;
```
### Cleaning Call Type Mapping
```SQL
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
```
### Validation 1.0 - Final Call Types Match
1.0 and 1.1 should return the same number of records
```SQL
SELECT
  c.final_call_type,
  COUNT(*) AS events
FROM spd_west.2023_clean c
LEFT JOIN spd_west.call_type_mapping_clean m
  ON c.final_call_type_key = m.final_call_type_key
WHERE m.final_call_type_key IS NULL
GROUP BY c.final_call_type
ORDER BY events DESC;
```
### Validation 1.1 - Final Call Types Match
```SQL
SELECT COUNT(*)
FROM spd_west.2023_clean c
JOIN spd_west.call_type_mapping_clean m
  ON c.final_call_type_key = m.final_call_type_key;
```
### Validation 2.0 - Distinct CAD numbers and Cleaned Events
Distinct CAD numbers and Cleaned events should match
```SQL
SELECT 
  COUNT(*) AS raw_rows,
  COUNT(DISTINCT cad_event_number) AS distinct_events
FROM spd_west.2023;
```
### Validation 2.1 - Distinct CAD numbers and Cleaned Events
```SQL
SELECT COUNT(*) AS clean_rows
FROM spd_west.2023_clean;
```
### Validation 3.0 - Null Service Time
Verify no record has zero service time
```SQL
SELECT COUNT(*) AS null_service_time_events
FROM spd_west.2023_clean
WHERE final_service_seconds IS NULL;
```
### Validation 4.0 - Pacific DATETIME NULL
This should return 0 records
```SQL
SELECT COUNT(*) 
FROM spd_west.2023_clean
WHERE pacific_event_datetime IS NULL;
```
### Validation 4.1 - Hour Distribution Checks
This should theoretically be lowest around 0300 - 0630, and peak between 1400 - 1600. This ensures there are not timezone parsing issues.
```SQL
SELECT
  EXTRACT(HOUR FROM pacific_event_datetime) AS hour,
  COUNT(*) AS events
FROM spd_west.2023_clean
GROUP BY hour
ORDER BY hour;
```
### Validation 5.0 - Erroneous Values - Service Time
Check for negatives
```SQL
SELECT
  MIN(final_service_seconds) AS min_seconds,
  MAX(final_service_seconds) AS max_seconds,
  AVG(final_service_seconds) AS avg_seconds
FROM spd_west.2023_clean;
```
### Validation 6.0 - Workload Logic
```SQL
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
```
Reactive: 85.1%
Organizational: 8.1%
Proactive: 6.8%

### Validation 
```SQL

```
### Validation 
```SQL

```
### Validation 
```SQL

```
### Validation 
```SQL

```


















## Distribution of Calls For Service
### Count of CFS - Hourly
``` SQL
SELECT
  EXTRACT(HOUR FROM pacific_event_datetime) AS hour_of_day,
  COUNT(*) AS call_count
FROM spd_west.2023_clean
WHERE final_call_type != 'OFF DUTY EMPLOYMENT'
GROUP BY hour_of_day
ORDER BY hour_of_day;
```

### Count of CFS - Day of Week
```SQL
SELECT
  FORMAT_TIMESTAMP('%A', pacific_event_datetime) AS day_of_week,
  EXTRACT(DAYOFWEEK FROM pacific_event_datetime) AS day_number,
  COUNT(*) AS call_count
FROM spd_west.2023_clean
WHERE final_call_type != 'OFF DUTY EMPLOYMENT'
GROUP BY day_of_week, day_number
ORDER BY day_number;
```
### Average Time Per CFS - Day of Week
```SQL
SELECT
  EXTRACT(DAYOFWEEK FROM pacific_event_datetime) AS day_number,
  FORMAT_TIMESTAMP('%A', pacific_event_datetime) AS day_of_week,
  SUM(final_service_seconds)/3600 AS total_service_hours,
  AVG(final_service_seconds)/60 AS avg_minutes_per_call
FROM spd_west.2023_clean
WHERE final_call_type != 'OFF DUTY EMPLOYMENT'
GROUP BY day_number, day_of_week
ORDER BY day_number;
```
### Count of CFS - Monthly
```SQL
SELECT
  EXTRACT(MONTH FROM pacific_event_datetime) AS month_number,
  FORMAT_TIMESTAMP('%B', pacific_event_datetime) AS month_name,
  COUNT(*) AS call_count
FROM spd_west.2023_clean
WHERE final_call_type != 'OFF DUTY EMPLOYMENT'
GROUP BY month_number, month_name
ORDER BY month_number;
```
## Estimated Time Consumed By Department
My objective here is to group calls by the total department time spent on the individual CAD event using the CAD event ID, and total service time. Calls will then be categorized based on how much total time the department allocated to the CAD event number in the following categories.
1. 0-1800 seconds (30 minutes),
2. 1800-3600 seconds (30 minutes - 1 hour),
3. 3600-10800 seconds (1-3 hours),
4. 10800-21600 seconds (3-6 hours),
5. 21600+ seconds (6+ hours)
With all calls categorized into times, we can then determine the top call types for each category to link nature of calls to actual time spent.

### Total Time Spent On Calls by Month
```SQL
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
```

### Creating call buckets
```SQL

```
### Number of calls per time bucket, and total time spent in each bucket by month.
```SQL

```

### Total Hours Worked distributed by time of day
```SQL

```
### Quantiles
```SQL
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
```

### Average time per bucket
```SQL
```

### Top 50 Calls
```SQL

```
### What percentage of labor is spent on the top 10% of calls?
-- Break calls into 10 equal categories (NILE) using window functions.
```SQL



```

### Onview vs. Dispatch
```SQL

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
