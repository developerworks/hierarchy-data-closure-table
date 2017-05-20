-- Table: public.prefix_nodes

-- DROP TABLE public.prefix_nodes;

CREATE TABLE public.prefix_nodes
(
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  "order" integer,
  name character varying(255),
  is_deleted boolean NOT NULL DEFAULT false,
  parent_id uuid,
  CONSTRAINT prefix_nodes_pkey PRIMARY KEY (id),
  CONSTRAINT prefix_nodes_parent_id_fkey FOREIGN KEY (parent_id)
      REFERENCES public.prefix_nodes (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.prefix_nodes
  OWNER TO postgres;

-- Index: public.prefix_nodes_parent_id_index

-- DROP INDEX public.prefix_nodes_parent_id_index;

CREATE INDEX prefix_nodes_parent_id_index
  ON public.prefix_nodes
  USING btree
  (parent_id);


-- Trigger: after_change_node on public.prefix_nodes

-- DROP TRIGGER after_change_node ON public.prefix_nodes;

CREATE TRIGGER after_change_node
  AFTER INSERT OR UPDATE
  ON public.prefix_nodes
  FOR EACH ROW
  EXECUTE PROCEDURE public.after_change_node();

------------------------------------------------------------------------------------------------------

-- Table: public.prefix_nodes_paths

-- DROP TABLE public.prefix_nodes_paths;

CREATE TABLE public.prefix_nodes_paths
(
  ancestor_id uuid NOT NULL,
  descendant_id uuid NOT NULL,
  depth integer,
  CONSTRAINT prefix_nodes_paths_pkey PRIMARY KEY (ancestor_id, descendant_id),
  CONSTRAINT prefix_nodes_paths_ancestor_id_fkey FOREIGN KEY (ancestor_id)
      REFERENCES public.prefix_nodes (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT prefix_nodes_paths_descendant_id_fkey FOREIGN KEY (descendant_id)
      REFERENCES public.prefix_nodes (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.prefix_nodes_paths
  OWNER TO postgres;

-- Index: public.prefix_nodes_paths_ancestor_id_index

-- DROP INDEX public.prefix_nodes_paths_ancestor_id_index;

CREATE INDEX prefix_nodes_paths_ancestor_id_index
  ON public.prefix_nodes_paths
  USING btree
  (ancestor_id);

-- Index: public.prefix_nodes_paths_descendant_id_index

-- DROP INDEX public.prefix_nodes_paths_descendant_id_index;

CREATE INDEX prefix_nodes_paths_descendant_id_index
  ON public.prefix_nodes_paths
  USING btree
  (descendant_id);


------------------------------------------------------------------------------------------------------


-- Function: public.get_child_nodes(uuid)

-- DROP FUNCTION public.get_child_nodes(uuid);

CREATE OR REPLACE FUNCTION public.get_child_nodes(uuid)
  RETURNS SETOF record AS
$BODY$
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
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.get_child_nodes(uuid)
  OWNER TO postgres;


------------------------------------------------------------------------------------------------------


-- Function: public.get_children_by_uuid(uuid)

-- DROP FUNCTION public.get_children_by_uuid(uuid);

CREATE OR REPLACE FUNCTION public.get_children_by_uuid(uuid)
  RETURNS json AS
$BODY$
DECLARE
  result json;
BEGIN
SELECT array_to_json(array_agg(row_to_json(t))) INTO result -- inject output into result variable
FROM ( -- same CTE as above
  WITH RECURSIVE genres_materialized_path AS (
    SELECT id, name, ARRAY[]::UUID[] AS path
    FROM prefix_nodes WHERE parent_id IS NULL

    UNION ALL

    SELECT prefix_nodes.id, prefix_nodes.name, genres_materialized_path.path || prefix_nodes.parent_id::UUID
    FROM prefix_nodes, genres_materialized_path
    WHERE prefix_nodes.parent_id = genres_materialized_path.id
  ) SELECT id, name, ARRAY[]::UUID[] AS children
  FROM genres_materialized_path WHERE $1 = genres_materialized_path.path[array_upper(genres_materialized_path.path,1)] -- some column polish for a cleaner JSON
) t;
RETURN result;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.get_children_by_uuid(uuid)
  OWNER TO postgres;



------------------------------------------------------------------------------------------------------



-- Function: public.get_tree(json)

-- DROP FUNCTION public.get_tree(json);

CREATE OR REPLACE FUNCTION public.get_tree(data json)
  RETURNS json AS
$BODY$
var root = [];
for(var i in data) {
  build_tree(data[i]['id'], data[i]['name'], data[i]['children']);
}
function build_tree(id, name, children) {
  var exists = getObject(root, id);
  if(exists) {
       exists['children'] = children;
  }
  else {
    root.push({'id': id, 'name': name, 'children': children});
  }
}
function getObject(theObject, id) {
  var result = null;
  if(theObject instanceof Array) {
    for(var i = 0; i < theObject.length; i++) {
      result = getObject(theObject[i], id);
      if (result) {
        break;
      }
    }
  }
  else
  {
    for(var prop in theObject) {
      if(prop == 'id') {
        if(theObject[prop] === id) {
            return theObject;
        }
      }
      if(theObject[prop] instanceof Object || theObject[prop] instanceof Array) {
        result = getObject(theObject[prop], id);
        if (result) {
            break;
        }
      }
    }
  }
  return result;
}
return JSON.stringify(root);
$BODY$
  LANGUAGE plv8 IMMUTABLE STRICT
  COST 100;
ALTER FUNCTION public.get_tree(json)
  OWNER TO postgres;


------------------------------------------------------------------------------------------------------



-- Function: public.move(uuid, uuid)

-- DROP FUNCTION public.move(uuid, uuid);

CREATE OR REPLACE FUNCTION public.move(
    uuid,
    uuid)
  RETURNS void AS
$BODY$
UPDATE prefix_nodes SET parent_id = $2 WHERE id = $1;

DELETE FROM prefix_nodes_paths
WHERE descendant_id IN (SELECT descendant_id FROM prefix_nodes_paths WHERE ancestor_id = $1)
AND ancestor_id     IN (SELECT ancestor_id   FROM prefix_nodes_paths WHERE descendant_id = $1 AND ancestor_id != descendant_id);

INSERT INTO prefix_nodes_paths (ancestor_id, descendant_id, depth)
SELECT supertree.ancestor_id, subtree.descendant_id, supertree.depth + subtree.depth + 1
FROM prefix_nodes_paths AS supertree
CROSS JOIN prefix_nodes_paths AS subtree
WHERE supertree.descendant_id = $2
AND subtree.ancestor_id = $1;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.move(uuid, uuid)
  OWNER TO postgres;
