
-- Find all the nodes within 2 hops of Node 94.

WITH RECURSIVE hops AS (
  SELECT node_id, neighbor_id AS reachable_node, 1 AS hop
  FROM `fms-prod-472514.fms_prod.network_structure`
  WHERE node_id = 'NODE94'
  UNION ALL
  SELECT e.node_id, e.neighbor_id, h.hop + 1
  FROM `fms-prod-472514.fms_prod.network_structure` e
  JOIN hops h ON e.node_id = h.reachable_node
  WHERE h.hop < 2
)
SELECT DISTINCT reachable_node AS node_id
FROM hops
WHERE hop > 0 AND hop <= 2;
