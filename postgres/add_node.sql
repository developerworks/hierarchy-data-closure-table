-----------------------------------------------
-- Add a new node to existing parent node.
--
-- If you want modify the `after_change_node` function,
-- you must delete the trigger from `prefix_nodes` table
-- first, and re-create it.
--
-----------------------------------------------

-- Drop trigger on a table
DROP TRIGGER IF EXISTS after_change_node ON prefix_nodes;

-- Drop trigger function
DROP FUNCTION IF EXISTS after_change_node();

-- Step 1: Create a function used to update paths
CREATE OR REPLACE FUNCTION after_change_node() RETURNS TRIGGER LANGUAGE PLPGSQL AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO prefix_nodes_paths(ancestor_id,descendant_id,depth)
    SELECT ancestor_id, NEW.id, depth + 1
    FROM prefix_nodes_paths WHERE descendant_id = NEW.parent_id
    UNION ALL SELECT NEW.id, NEW.id, 0;
  END IF;
  RETURN NULL;
END;
$$;

-- Add trigger function on prefix_nodes table
CREATE TRIGGER after_change_node AFTER INSERT OR UPDATE
  ON prefix_nodes FOR EACH ROW EXECUTE PROCEDURE after_change_node();



