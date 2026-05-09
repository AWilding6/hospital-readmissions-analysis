-- ================================================
-- Hospital Readmissions Reduction Program
-- Dataset: FY2026 Hospital Readmissions Reduction Program
-- Author: Andrew Wilding
-- ================================================

-- ================================================
-- Step 1: Create and import data
-- ================================================

CREATE DATABASE healthcare;
USE healthcare;

-- Create readmissions table
CREATE TABLE readmissions (
	facility        VARCHAR(100),
	facility_id     VARCHAR(20),
    state           VARCHAR(5),
    measure         VARCHAR(100),
    discharge_num   int,
    footnote        VARCHAR(255),
    excess_ratio    float,
    predicted_ratio float,
    expected_ratio  float,
    readmissions    int,
    start_date      DATE,
    end_date        DATE
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE "C:/Users/HoldT/Documents/SQL Projects/hospital readmissions project/FY_2026_Hospital_Readmissions_Reduction_Program_Hospital.csv"
INTO TABLE readmissions
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@facility, @facility_id, @state, @measure, @discharge_num, @footnote, @excess_ratio, @predicted_ratio, @expected_ratio, @readmissions, @start_date, @end_date)
SET
    facility        = TRIM(REPLACE(@facility, '\r', '')),
    facility_id     = @facility_id,
    state           = @state,
    measure         = @measure,
    discharge_num   = NULLIF(TRIM(@discharge_num), 'N/A'),
    footnote        = NULLIF(TRIM(@footnote), ''),
    excess_ratio    = NULLIF(TRIM(@excess_ratio), 'N/A'),
    predicted_ratio = NULLIF(TRIM(@predicted_ratio), 'N/A'),
    expected_ratio  = NULLIF(TRIM(@expected_ratio), 'N/A'),
    readmissions    = NULLIF(NULLIF(TRIM(@readmissions), 'N/A'), 'Too Few to Report'),
    start_date      = STR_TO_DATE(TRIM(REPLACE(@start_date, '\r', '')), '%m/%d/%Y'),
    end_date        = STR_TO_DATE(TRIM(REPLACE(@end_date, '\r', '')), '%m/%d/%Y');
    
SELECT COUNT(*) FROM readmissions; -- 18330

-- ================================================
-- Step 2: Data Cleaning
-- ================================================

-- Disable Safe Mode temporarily for cleaning
SET SQL_SAFE_UPDATES = 0;

-- Remove rows where excess_ratio is NULL
-- (these are hospitals with insufficient data to calculate a ratio)
DELETE FROM readmissions
WHERE excess_ratio IS NULL;

SELECT COUNT(*) FROM readmissions; -- 11720

-- Remove rows where discharge_num is NULL
-- (no discharge data means we can't do volume analysis)
DELETE FROM readmissions
WHERE discharge_num IS NULL;

SELECT COUNT(*) FROM readmissions; -- 8037

-- Final check before moving to analysis
SELECT
    SUM(CASE WHEN excess_ratio IS NULL THEN 1 ELSE 0 END) AS null_ratios,
    SUM(CASE WHEN discharge_num IS NULL THEN 1 ELSE 0 END) AS null_discharges,
    ROUND(MIN(excess_ratio), 4) AS min_ratio,
    ROUND(MAX(excess_ratio), 4) AS max_ratio,
    MIN(discharge_num) AS min_discharges,
    MAX(discharge_num) AS max_discharges
FROM readmissions;

SET SQL_SAFE_UPDATES = 1;
