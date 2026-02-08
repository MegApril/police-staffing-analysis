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

-- Create table with unique cad event times and earliest timestamp and save as new table named 2023_events_times
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

-- Fixed data type in timestamp column from STRING to TIMESTAMP
```SQL
CREATE OR REPLACE TABLE
  `spd_west.2023_events_times` AS
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
