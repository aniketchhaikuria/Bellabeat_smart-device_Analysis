# Counting the occurrences of each column in the database and labeling them with column_count
SELECT
  column_name,
  COUNT(table_name) AS column_count
FROM
  `durable-epoch-418201.bellabeat_data_analysis.INFORMATION_SCHEMA.COLUMNS`
GROUP BY
  1;

# Checking if each table has an "Id" column and counting how many tables have it
SELECT
  table_name,
  SUM(CASE
      WHEN column_name = "Id" THEN 1
    ELSE
    0
  END) AS has_id_column
FROM
  `durable-epoch-418201.bellabeat_data_analysis.INFORMATION_SCHEMA.COLUMNS`
GROUP BY
  1
ORDER BY
  1 ASC;

# Identifying tables that lack timestamp, datetime, or date columns
SELECT
  table_name,
  SUM(CASE
      WHEN data_type IN ("TIMESTAMP", "DATETIME", "TIME", "DATE") THEN 1
    ELSE
    0
  END) AS has_time_info
FROM
  `durable-epoch-418201.bellabeat_data_analysis.INFORMATION_SCHEMA.COLUMNS`
WHERE
  data_type IN ("TIMESTAMP", "DATETIME", "DATE")
GROUP BY
  1
HAVING
  has_time_info = 0;

# Listing tables along with their columns that contain timestamp, datetime, or date information
SELECT
  CONCAT(table_catalog,".",table_schema,".",table_name) AS table_path,
  table_name,
  column_name
FROM
  `durable-epoch-418201.bellabeat_data_analysis.INFORMATION_SCHEMA.COLUMNS`
WHERE
  data_type IN ("TIMESTAMP", "DATETIME", "DATE");

# Selecting columns with names indicative of time information like "date," "minute," "daily," etc.
SELECT
  table_name,
  column_name
FROM
  `durable-epoch-418201.bellabeat_data_analysis.INFORMATION_SCHEMA.COLUMNS`
WHERE
  REGEXP_CONTAINS(LOWER(column_name), "date|minute|daily|hourly|day|seconds");

# Selecting a few rows from a table and determining if the "ActivityDate" column follows the expected timestamp format
SELECT
  ActivityDate,
  REGEXP_CONTAINS(STRING(ActivityDate), r'^\d{4}-\d{1,2}-\d{1,2}[T ]\d{1,2}:\d{1,2}:\d{1,2}(\.\d{1,6})? *(([+-]\d{1,2}(:\d{1,2})?)|Z|UTC)?$') AS is_timestamp
FROM
  `durable-epoch-418201.bellabeat_data_analysis.dailyActivity_merged`
LIMIT
  5;

# Checking if all values in the "ActivityDate" column of a table follow the specified timestamp format
SELECT
  CASE
    WHEN MIN(REGEXP_CONTAINS(STRING(ActivityDate), r'^\d{4}-\d{1,2}-\d{1,2}[T ]\d{1,2}:\d{1,2}:\d{1,2}(\.\d{1,6})? *(([+-]\d{1,2}(:\d{1,2})?)|Z|UTC)?$')) THEN "Valid"
    ELSE "Not Valid"
  END AS valid_test
FROM
  `durable-epoch-418201.bellabeat_data_analysis.dailyActivity_merged`;

# Checking if all values in the "ActivityDate" column of a table follow a simplified timestamp format
DECLARE TIMESTAMP_REGEX STRING DEFAULT r'^\d{4}-\d{1,2}-\d{1,2}$';
SELECT
  CASE
    WHEN MIN(REGEXP_CONTAINS(STRING(ActivityDate), TIMESTAMP_REGEX)) = TRUE THEN "Valid"
  ELSE
  "Not Valid"
  END
  AS valid_test
FROM
  `durable-epoch-418201.bellabeat_data_analysis.dailyActivity_merged`;

# Listing tables whose names contain "day" or "daily"
SELECT
  DISTINCT table_name
FROM
  `durable-epoch-418201.bellabeat_data_analysis.INFORMATION_SCHEMA.COLUMNS`
WHERE
  REGEXP_CONTAINS(LOWER(table_name),"day|daily");

# Counting the occurrence of each column type in tables with names containing "day" or "daily"
SELECT
  column_name,
  data_type,
  COUNT(table_name) AS table_count
FROM
  `durable-epoch-418201.bellabeat_data_analysis.INFORMATION_SCHEMA.COLUMNS`
WHERE
  REGEXP_CONTAINS(LOWER(table_name),"day|daily")
GROUP BY
  1,
  2;

# Selecting columns from tables with names containing "day" or "daily" that appear in more than one table
SELECT
  column_name,
  table_name,
  data_type
FROM
  `durable-epoch-418201.bellabeat_data_analysis.INFORMATION_SCHEMA.COLUMNS`
WHERE
  REGEXP_CONTAINS(LOWER(table_name),"day|daily")
  AND column_name IN (
    SELECT
      column_name
    FROM
      `durable-epoch-418201.bellabeat_data_analysis.INFORMATION_SCHEMA.COLUMNS`
    WHERE
      REGEXP_CONTAINS(LOWER(table_name),"day|daily")
    GROUP BY
      1
    HAVING
      COUNT(table_name) >=2)
ORDER BY
  1;

# Joining multiple daily activity-related tables and incorporating information from sleep data for further analysis
SELECT
  A.Id,
  A.Calories,
  * EXCEPT(Id,
    Calories,
    ActivityDay,
    SedentaryMinutes,
    LightlyActiveMinutes,
    FairlyActiveMinutes,
    VeryActiveMinutes,
    SedentaryActiveDistance,
    LightActiveDistance,
    ModeratelyActiveDistance,
    VeryActiveDistance),
  I.SedentaryMinutes,
  I.LightlyActiveMinutes,
  I.FairlyActiveMinutes,
  I.VeryActiveMinutes,
  I.SedentaryActiveDistance,
  I.LightActiveDistance,
  I.ModeratelyActiveDistance,
  I.VeryActiveDistance,
  Sl.SleepDate
FROM
  `durable-epoch-418201.bellabeat_data_analysis.dailyActivity_merged` A
LEFT JOIN
  `durable-epoch-418201.bellabeat_data_analysis.dailyCalories_merged` C
ON
  A.Id = C.Id
  AND A.ActivityDate=C.ActivityDay
  AND A.Calories = C.Calories
LEFT JOIN
  `durable-epoch-418201.bellabeat_data_analysis.dailyIntensities_merged` I
ON
  A.Id = I.Id
  AND A.ActivityDate=I.ActivityDay
  AND A.FairlyActiveMinutes = I.FairlyActiveMinutes
  AND A.LightActiveDistance = I.LightActiveDistance
  AND A.LightlyActiveMinutes = I.LightlyActiveMinutes
  AND A.ModeratelyActiveDistance = I.ModeratelyActiveDistance
  AND A.SedentaryActiveDistance = I.SedentaryActiveDistance
  AND A.SedentaryMinutes = I.SedentaryMinutes
  AND A.VeryActiveDistance = I.VeryActiveDistance
  AND A.VeryActiveMinutes = I.VeryActiveMinutes
LEFT JOIN
  `durable-epoch-418201.bellabeat_data_analysis.dailySteps_merged` S
ON
  A.Id = S.Id
  AND A.ActivityDate=S.ActivityDay
LEFT JOIN (
    SELECT
      Id,
      PARSE_DATE('%m/%d/%y', SPLIT(SleepDay, ' ')[OFFSET(0)]) AS SleepDate
    FROM
      `durable-epoch-418201.bellabeat_data_analysis.sleepDay_merged`
) Sl
ON
  A.Id = Sl.Id
  AND A.ActivityDate = Sl.SleepDate;
