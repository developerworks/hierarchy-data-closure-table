DROP FUNCTION IF EXISTS move(UUID, UUID);

CREATE FUNCTION move(
  UUID,
  UUID
) RETURNS VOID
AS $$
--------------------------------------------
-- Step 1: Update parent node id
--------------------------------------------
UPDATE prefix_nodes SET parent_id = $2 WHERE id = $1;

--------------------------------------------
-- Step 2: Disconnect from current ancestors
-- Delete all paths that end at descendants in the subtree
--------------------------------------------
DELETE FROM prefix_nodes_paths
WHERE descendant_id IN (SELECT descendant_id FROM prefix_nodes_paths WHERE ancestor_id = $1)
AND ancestor_id     IN (SELECT ancestor_id   FROM prefix_nodes_paths WHERE descendant_id = $1 AND ancestor_id != descendant_id);

--------------------------------------------
-- Step 2: Mount subtree to new ancestors
-- Insert rows matching ancestors of insertion point and descendants of subtree
--------------------------------------------
INSERT INTO prefix_nodes_paths (ancestor_id, descendant_id, depth)
SELECT supertree.ancestor_id, subtree.descendant_id, supertree.depth + subtree.depth + 1
FROM prefix_nodes_paths AS supertree
CROSS JOIN prefix_nodes_paths AS subtree
WHERE supertree.descendant_id = $2
AND subtree.ancestor_id = $1;
$$ LANGUAGE SQL;
