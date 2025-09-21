WITH prior_failures AS (
  SELECT
    *,
    COALESCE(
      SUM(CASE WHEN outcome = 'FAIL' THEN 1 ELSE 0 END)
      OVER (PARTITION BY task_id ORDER BY visit_id ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),
    0) AS prior_failures_count
  FROM fms-prod-472514.fms_prod.visits_information

)

SELECT
  task_id,
  node_id,
  visit_id,
  visit_date,
  engineer_skill_level,
  outcome
FROM prior_failures
WHERE
  DATE(visit_date) BETWEEN '2020-01-01' AND '2020-03-31'
  AND outcome = 'SUCCESS'
  AND engineer_skill_level > 2
  AND prior_failures_count >= 2;
