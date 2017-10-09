------------------------------------------
-- Get tree
------------------------------------------

DROP FUNCTION IF EXISTS get_tree(data json);

CREATE OR REPLACE FUNCTION get_tree(data json)
RETURNS json
AS $$
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
    root.push({'id': id, 'name': name, 'children': children, 'toggled': true});
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
    theObject['toggled'] = true;
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
$$ LANGUAGE plv8 IMMUTABLE STRICT;

------------------------------------------
-- Format to JSON Object(The Whole Trees)
------------------------------------------

WITH data AS(
SELECT array_to_json(array_agg(row_to_json(t))) AS data
  FROM (
   SELECT id, name, COALESCE(get_children_by_uuid(id), '[]') AS children, 'true' FROM prefix_nodes
  ) t
) SELECT get_tree(data) FROM data;
