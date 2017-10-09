--------------------------------------------
-- Delete a leaf
--------------------------------------------



--------------------------------------------
-- Delete a subtree
--------------------------------------------

DROP FUNCTION IF EXISTS delete_subtree(INTEGER);

CREATE FUNCTION delete_subtree(INTEGER)
RETURNS VOID
AS $$
  DELETE FROM prefix_nodes_paths
  WHERE descendant_id IN (
    SELECT descendant_id FROM prefix_nodes_paths WHERE ancestor_id = $1
  );
$$ LANGUAGE sql
