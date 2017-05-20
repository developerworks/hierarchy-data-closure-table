-----------------------------------------------------------------------
-- Get child nodes
-----------------------------------------------------------------------


DROP FUNCTION IF EXISTS get_child_nodes(UUID);

-- Create function
CREATE FUNCTION get_child_nodes(UUID)
  RETURNS SETOF RECORD
AS $$
SELECT d.id,
       d.is_deleted,
       d.parent_id,
       concat(repeat('-', p.depth), d.name) AS name,
       p.depth,
       array_to_string(array_agg(crumbs.ancestor_id::CHARACTER VARYING),',','*') breadcrumbs
  FROM prefix_nodes AS d
  JOIN prefix_nodes_paths AS p ON d.id = p.descendant_id
  JOIN prefix_nodes_paths AS crumbs ON crumbs.descendant_id = p.descendant_id
 WHERE p.ancestor_id = $1 AND d.is_deleted = false
 GROUP BY d.id, p.depth
 ORDER BY d.id ASC
 ;
$$ LANGUAGE SQL;



-----------------------------------------------------------------------
-- Get subtree(Depend on `get_child_nodes` user defined function above)
-- (include node itself, such as following statement, node #2)
-- TODO
-- 1. Add a switch(boolean value) if include node itself
-----------------------------------------------------------------------


SELECT * FROM get_child_nodes('29f9d3a1-068f-4132-bf5e-4792add8489b')
  AS (id UUID,is_deleted BOOLEAN,parent_id UUID,name VARCHAR(255),depth INTEGER,breadcrumbs VARCHAR(255))
  ORDER BY breadcrumbs;

