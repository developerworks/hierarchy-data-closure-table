# Closure Table


This is a mysql store procedure and trigger implementation of closure table in
RDBMS about hierarchy data model.

<h3>Closure Table Node Paths</h3>

![Closure Table Node Paths](https://raw.github.com/developerworks/hierarchy-data-closure-table/master/assets/closure-table-paths.png "Closure Table Node Paths")

<h3>Query the subtree nodes</h3>

![Query the subtree nodes](https://raw.github.com/developerworks/hierarchy-data-closure-table/master/assets/call%20p_prefix_nodes_get_subtree_by_node_id.png "Query the subtree nodes")

## Features


* Automatically add new paths when you insert a new node

* Automatically update(`DELETE` old paths and `INSERT` new paths) paths when you
update `parent_id` of a node. (This means move a node/subtree to a new parent)

* A store procedure that is used to select a whole subtree by a `node_id`
(if the `node_id` has descendant)


## Triggers


* `trigger_add_paths`

The trigger is execute when insert a node into `prefix_nodes` table, and call `p_node_add` to add update paths.

* `prefix_node_move`:

The trigger is execute when update the `parent_id` column of `prefix_nodes`
table only if `OLD.parent_id != NEW.parent_id`

## Store Procedures


* `p_node_add(param_node_new_id INT UNSIGNED,param_node_parent_id INT UNSIGNED)`

  Add new paths when insert a node to `prefix_nodes` table

* `p_get_tree(node_id INT UNSIGNED)`

  Get subtree by a node id

* `p_node_move(node_old_parent_id INT UNSIGNED,node_new_parent_id INT UNSIGNED)`

  Update paths when move a node to a new parent node

* `p_node_hide(node_id INT UNSIGNED, is_deleted INT UNSIGNED)`

  Hide or show nodes from subtree, explains as following:

  - Step 1. `call p_get_tree(6)` get the `HARDWARE` subtree,
  - Step 2. `call p_node_hide(6, 0)` to hide a subtree,
  - Step 3. `call p_get_tree(6)` get the `HARDWARE` subtree, when you get a subtree, it is not show in the result.
  - Step 4. `call p_node_hide(6, 1)` show `HARDWARE` subtree

## Files

* `./sql/tables.sql`

  Create tables.

* `./sql/sample_data.sql`

  Some insert statements for testing
