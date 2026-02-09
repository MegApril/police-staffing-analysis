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

-- Create table with unique cad event times and earliest timestamp. Save as new table named 2023_events_times
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

-- Created new table with a new column for timestamps with the appropriate data type.
```SQL
CREATE OR REPLACE TABLE
  `spd_west.2023_events_timestamped` AS
SELECT
  cad_event_number,
  event_time,

  -- parsed, timezone-aware timestamp
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
