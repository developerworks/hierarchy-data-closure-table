----------------
-- Get child nodes
----------------

DROP FUNCTION IF EXISTS get_child_nodes(INTEGER);

-- Create function
CREATE FUNCTION get_child_nodes(INTEGER)
  RETURNS SETOF RECORD
  LANGUAGE SQL
AS $$
SELECT d.id,
       d.is_deleted,
       d.parent_id,
       concat(repeat('-', p.depth), d.name) AS tree,
       p.depth,
       array_to_string(array_agg(crumbs.ancestor_id::CHARACTER VARYING ORDER BY crumbs.ancestor_id),',','*') breadcrumbs
  FROM prefix_nodes AS d
  JOIN prefix_nodes_paths AS p ON d.id = p.descendant_id
  JOIN prefix_nodes_paths AS crumbs ON crumbs.descendant_id = p.descendant_id
 WHERE p.ancestor_id = $1 AND d.is_deleted = false
 GROUP BY d.id, p.depth
 ORDER BY d.id ASC
 ;
$$

