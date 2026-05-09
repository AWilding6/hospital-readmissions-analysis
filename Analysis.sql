-- ================================================
-- Step 3: Analysis
-- ================================================

-- Average excess readmission ratio by condition
SELECT
	measure,
    ROUND(AVG(excess_ratio), 4) AS avg_excess_ratio,
    COUNT(*) AS hospital_count,
    ROUND(MIN(excess_ratio), 4) AS best_performer,
    ROUND(MAX(excess_ratio), 4) AS worst_performer
FROM readmissions
GROUP BY measure
ORDER BY avg_excess_ratio DESC;

-- Average excess readmission ratio by state
SELECT
	state,
	ROUND(AVG(excess_ratio), 4) AS avg_excess_ratio,
    COUNT(*) AS total_records,
    COUNT(DISTINCT facility_id) AS hospital_count
FROM readmissions
GROUP BY state
ORDER BY avg_excess_ratio DESC; 

-- Hospital volume vs performance
SELECT
	CASE
		WHEN discharge_num <= 500 THEN 'Low (<=500)'
        WHEN discharge_num <= 1500 THEN 'Medium (501-1500)'
        ELSE 'High (>1500)'
	END AS volume_bucket,
    COUNT(DISTINCT facility_id) AS hospital_count,
    ROUND(AVG(excess_ratio), 4) AS avg_excess_ratio,
	ROUND(MIN(excess_ratio), 4) AS best_performer,
    ROUND(MAX(excess_ratio), 4) AS worst_performer
FROM readmissions
GROUP BY volume_bucket
ORDER BY avg_excess_ratio DESC;

-- Worst performing hospitals (top 20)
SELECT
	facility,
    state,
    measure,
    excess_ratio,
    discharge_num
FROM readmissions
WHERE excess_ratio > 1
ORDER BY excess_ratio DESC
LIMIT 20;

-- Best performing hospitals (top 20)
SELECT
	facility,
    state,
    measure,
    excess_ratio,
    discharge_num
FROM readmissions
WHERE excess_ratio < 1
ORDER BY excess_ratio DESC
LIMIT 20;