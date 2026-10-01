-- Equipment Hire Analysis (synthetic data) | BigQuery
-- Table paths use my project ID. Change them if you copy this.

-- 1. Clean the data: remove duplicates, fix depot names, fill blank customers
CREATE OR REPLACE TABLE `project-cc8cddff-8563-49bc-b21.equipment_hire.hire_clean` AS
SELECT DISTINCT
  contract_number,
  COALESCE(NULLIF(TRIM(customer), ''), 'Unknown') AS customer,
  equipment_type,
  equipment_category,
  INITCAP(TRIM(depot)) AS depot,
  hire_start,
  expected_off_hire,
  off_hire_logged,
  collected_date,
  daily_rate_gbp,
  days_on_hire,
  damage_charge_gbp
FROM `project-cc8cddff-8563-49bc-b21.equipment_hire.hire_raw`;

-- 2. Check the clean table (expect 800 rows and 10 depots)
SELECT COUNT(*) AS rows_after,
       COUNT(DISTINCT depot) AS depots
FROM `project-cc8cddff-8563-49bc-b21.equipment_hire.hire_clean`;

-- 3. Company-wide averages (the benchmark for every depot)
SELECT
  COUNT(*) AS total_hires,
  COUNTIF(off_hire_logged IS NULL) AS missing_off_hires,
  ROUND(COUNTIF(off_hire_logged IS NULL) / COUNT(*) * 100, 1) AS missing_pct,
  COUNTIF(DATE_DIFF(collected_date, off_hire_logged, DAY) > 3) AS late_collections,
  ROUND(COUNTIF(DATE_DIFF(collected_date, off_hire_logged, DAY) > 3) / COUNT(*) * 100, 1) AS late_pct
FROM `project-cc8cddff-8563-49bc-b21.equipment_hire.hire_clean`;

-- 4. Missing off-hires by depot
SELECT
  depot,
  COUNT(*) AS total_hires,
  COUNTIF(off_hire_logged IS NULL) AS missing_off_hires,
  ROUND(COUNTIF(off_hire_logged IS NULL) / COUNT(*) * 100, 1) AS missing_pct
FROM `project-cc8cddff-8563-49bc-b21.equipment_hire.hire_clean`
GROUP BY depot
ORDER BY missing_pct DESC;

-- 5. Late collections by depot (late = more than 3 days after off-hire)
SELECT
  depot,
  COUNT(*) AS total_hires,
  COUNTIF(DATE_DIFF(collected_date, off_hire_logged, DAY) > 3) AS late_collections,
  ROUND(COUNTIF(DATE_DIFF(collected_date, off_hire_logged, DAY) > 3) / COUNT(*) * 100, 1) AS late_pct
FROM `project-cc8cddff-8563-49bc-b21.equipment_hire.hire_clean`
GROUP BY depot
ORDER BY late_pct DESC;

-- 6. Both problems by equipment category
SELECT
  equipment_category,
  COUNT(*) AS total_hires,
  COUNTIF(off_hire_logged IS NULL) AS missing_off_hires,
  ROUND(COUNTIF(off_hire_logged IS NULL) / COUNT(*) * 100, 1) AS missing_pct,
  COUNTIF(DATE_DIFF(collected_date, off_hire_logged, DAY) > 3) AS late_collections,
  ROUND(COUNTIF(DATE_DIFF(collected_date, off_hire_logged, DAY) > 3) / COUNT(*) * 100, 1) AS late_pct
FROM `project-cc8cddff-8563-49bc-b21.equipment_hire.hire_clean`
GROUP BY equipment_category
ORDER BY late_pct DESC;

-- 7. Hires with no collection date at all
SELECT COUNT(*) AS no_collection_date
FROM `project-cc8cddff-8563-49bc-b21.equipment_hire.hire_clean`
WHERE collected_date IS NULL;
