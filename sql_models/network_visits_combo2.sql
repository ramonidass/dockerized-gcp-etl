
-- Find all the nodes that are within 2 hops of Node 94
-- and have also been associated with at least 10 failed visits during 2020.

WITH RECURSIVE hops AS (
  SELECT node_id, neighbor_id AS reachable_node, 1 AS hop
  FROM `fms-prod-472514.fms_prod.network_structure`
  WHERE node_id = 'NODE94'
  UNION ALL
  SELECT e.node_id, e.neighbor_id, h.hop + 1
  FROM `fms-prod-472514.fms_prod.network_structure` e
  JOIN hops h ON e.node_id = h.reachable_node
  WHERE h.hop < 2
),
FailedVisits AS (
  SELECT node_id, COUNT(*) AS failed_count
  FROM `fms-prod-472514.fms_prod.visits_information`
  WHERE outcome = 'FAIL'
    AND EXTRACT(YEAR FROM visit_date) = 2020
  GROUP BY node_id
  HAVING failed_count >= 10
)
SELECT DISTINCT h.reachable_node AS node_id
FROM hops h
JOIN FailedVisits f ON h.reachable_node = f.node_id
WHERE hop > 0 AND hop <= 2;
