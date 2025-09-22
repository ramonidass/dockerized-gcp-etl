
-- Find all the nodes that are within 2 hops of Node 94
-- and have been associated with at least 1 visit that took place between
-- 1/3/2020 and 31/3/2020 and for which the visiting engineer’s note included
-- the token ‘126’.

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
MatchingVisits AS (
  SELECT DISTINCT node_id
  FROM `fms-prod-472514.fms_prod.visits_information`
  WHERE visit_date BETWEEN '2020-03-01' AND '2020-03-31'
    AND 126 IN UNNEST(engineer_note)  -- Check if 126 is in the array
)
SELECT DISTINCT h.reachable_node AS node_id
FROM hops h
JOIN MatchingVisits m ON h.reachable_node = m.node_id
WHERE hop > 0 AND hop <= 2;
