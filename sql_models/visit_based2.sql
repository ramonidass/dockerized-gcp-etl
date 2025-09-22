
-- Find all tasks that were successfully completed after 2 visits and
-- the 2 engineer notes left after the visits include at least 5 words in common.

WITH TaskVisits AS (
  SELECT task_id,
         ARRAY_AGG(STRUCT(visit_id, engineer_note, outcome) ORDER BY visit_id) AS visit_details
  FROM `fms-prod-472514.fms_prod.visits_information`
  GROUP BY task_id
  HAVING ARRAY_LENGTH(visit_details) = 3
     AND visit_details[SAFE_OFFSET(2)].outcome = 'SUCCESS'
),
NoteComparison AS (
  SELECT t.task_id,
         visit_details[SAFE_OFFSET(0)].engineer_note AS note1,
         visit_details[SAFE_OFFSET(1)].engineer_note AS note2  
  FROM TaskVisits t
)
SELECT task_id
FROM NoteComparison
WHERE ARRAY_LENGTH(
  ARRAY(
    SELECT token
    FROM UNNEST(note1) token
    INTERSECT DISTINCT
    SELECT token
    FROM UNNEST(note2) token
  )
) >= 5;
