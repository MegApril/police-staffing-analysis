# SQL Queries
## Distribution of Calls For Service

-- Determine number of duplicates for cad events
```SQL
SELECT
  cad_event_number,
    COUNT(*) AS record_count
FROM `police-staffing-spd-west.spd_west.2023`
GROUP BY cad_event_number
HAVING COUNT(*) > 1
ORDER BY record_count DESC;
```

-- Create table with unique cad event times and earliest timestamp.
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

-- Create new table with timestamps in pacific time from UTC, and with the appropriate data type for analysis
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

-- Number of calls grouped by hour
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

-- Number of calls grouped by day of the week
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

-- Number of calls grouped by Month
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

-- Create calls base table with unique cad events, total service time and the final call type. 
-- Adressing service time data type issue, trimming white space, stripping commas, returning true NULL's only if the string is empty... while retaining unique CAD event.
```SQL
CREATE OR REPLACE TABLE `spd_west.2023_calls_base` AS
SELECT
  cad_event_number,

  MAX(
    SAFE_CAST(
      NULLIF(
        REGEXP_REPLACE(
          TRIM(spd_call_sign_total_service_time_in_seconds),
          r',',
          ''
        ),
        ''
      ) AS INT64
    )
  ) AS total_service_seconds,

  ANY_VALUE(final_call_type) AS final_call_type

FROM `spd_west.2023`
WHERE spd_call_sign_total_service_time_in_seconds IS NOT NULL
GROUP BY cad_event_number;
```
This returned 97,732 records which is 7 fewer than the unique cad table from Distribution of Calls for Service

-- Validating the data cleaning worked
```SQL
SELECT
  COUNT(*) AS total_calls,
  COUNT(total_service_seconds) AS parsed_calls,
  COUNT(*) - COUNT(total_service_seconds) AS still_null,
  MIN(total_service_seconds) AS min_sec,
  MAX(total_service_seconds) AS max_sec
FROM `spd_west.2023_calls_base`;
```
### Troubleshooting Side Quest
```SQL
SELECT
  COUNT(DISTINCT cad_event_number) AS total_calls,
  COUNT(DISTINCT IF(spd_call_sign_total_service_time_in_seconds IS NOT NULL,
                    cad_event_number,
                    NULL)) AS calls_with_service_time,
  COUNT(DISTINCT IF(spd_call_sign_total_service_time_in_seconds IS NULL,
                    cad_event_number,
                    NULL)) AS calls_missing_service_time
FROM `spd_west.2023`;
```
|Total Calls| Calls with Service Time| Calls Missing Service Time|
|---|---|---|
|97739|97732|152|

-- Isolating the 7 calls to determine if they are important to the analysis
```SQL
-- Set A: calls-for-service universe
WITH calls_dist AS (
  SELECT DISTINCT cad_event_number
  FROM `spd_west.2023`
),

-- Set B: time-analysis universe
calls_time AS (
  SELECT DISTINCT cad_event_number
  FROM `spd_west.2023_calls_base`
)

SELECT
  cad_event_number
FROM calls_dist
EXCEPT DISTINCT
SELECT
  cad_event_number
FROM calls_time;
```

