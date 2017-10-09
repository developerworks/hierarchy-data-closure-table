-----------------------------------------------
-- This function is used to update paths when
-- inserted a new node to a exist parent node.
-----------------------------------------------

-- Drop function
DROP FUNCTION IF EXISTS after_change_node();

-- Step 1: Create a function used to update paths
CREATE OR REPLACE FUNCTION after_change_node() RETURNS TRIGGER LANGUAGE PLPGSQL AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO prefix_nodes_paths(ancestor_id,descendant_id,depth)
    SELECT ancestor_id, NEW.id, depth + 1
    FROM prefix_nodes_paths WHERE descendant_id = NEW.parent_id
    UNION ALL SELECT NEW.id, NEW.id, 0;
  ELSE IF (TG_OP = 'UPDATE') THEN
    -- Move Subtree
    -- References:
    -- https://codegists.com/snippet/sql/closure_treesql_x2002uwh_sql
    IF OLD.parent_id != NEW.parent_id THEN
      -- Step 1: Disconnect from current ancestors
      DELETE FROM prefix_nodes_paths
      WHERE descendant_id IN (SELECT descendant_id FROM prefix_nodes_paths WHERE ancestor_id = OLD.parent_id)
          AND ancestor_id IN (SELECT ancestor_id   FROM prefix_nodes_paths WHERE descendant_id = OLD.parent_id AND ancestor_id != descendant_id);

      -- Step 2: Insert rows matching ancestors of insertion point and descendants of subtree
      INSERT INTO prefix_nodes_paths (ancestor, descendant)
        SELECT supertree.ancestor, subtree.descendant
        FROM prefix_nodes_paths AS supertree
        CROSS JOIN prefix_nodes_paths AS subtree
        WHERE supertree.descendant = 3
        AND subtree.ancestor = 6;


      -- Add new paths
      INSERT prefix_nodes_paths (ancestor_id, descendant_id, depth)
        SELECT supertree.ancestor_id, subtree.descendant_id, supertree.path_length + subtree.path_length + 1
        FROM prefix_nodes_paths AS supertree
        JOIN prefix_nodes_paths AS subtree
        WHERE subtree.ancestor_id = OLD.parent_id
        AND supertree.descendant_id = NEW.parent_id ;

    END IF;
  END IF;
  RETURN NULL;
END;
$$;


-- Add trigger function on prefix_nodes table
CREATE TRIGGER after_change_node AFTER INSERT OR UPDATE
  ON prefix_nodes FOR EACH ROW EXECUTE PROCEDURE after_change_node();

--
-- If you want modify the `after_change_node` function,
-- you must delete the trigger from `prefix_nodes` table
-- first, and re-create it.
--

-- Drop trigger function on a table
DROP TRIGGER IF EXISTS after_change_node ON prefix_nodes;



