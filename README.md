Closure Table
=============

This is a mysql store procedure and trigger implementation of closure table in RDBMS about hierarchy data model.

<h3>Closure Table Node Paths</h3>

![Closure Table Node Paths](https://raw.github.com/developerworks/hierarchy-data-closure-table/master/assets/closure-table-paths.png "Closure Table Node Paths")

<h3>Query the subtree nodes</h3>

![Query the subtree nodes](https://raw.github.com/developerworks/hierarchy-data-closure-table/master/assets/call%20p_prefix_nodes_get_subtree_by_node_id.png "Query the subtree nodes")


Features
--------

* Automatically add new paths relationship information between ancester and descendant nodes when you insert node to table `prefix_nodes`
* Automatically update(`DELETE` old paths and `INSERT` new paths) paths relationship information when you update the `parent_id` column of `prefix_nodes` table if the new value parent_id if different(This means move a node/subtree to a new parent node)
* A store procedure that is used to select a whole subtree by a `node_id` (if the `node_id` has descendant)



Triggers
--------

* `prefix_nodes_add_new_paths_after_insert`
The trigger is execute when insert a node into `prefix_nodes` table, and call `p_prefix_nodes_add_new_paths_after_insert` to add new paths info.

* `prefix_nodes_move_old_paths_after_update`:
The trigger is execute when update the `parent_id` column of `prefix_nodes` table only if `OLD.parent_id != NEW.parent_id`

Store Procedures
----------------

It's very clear of means just like the name of the procedures.

* `p_prefix_nodes_add_new_paths_after_insert(param_node_new_id INT UNSIGNED,param_node_parent_id INT UNSIGNED)`

  Add new paths when insert a node to `prefix_nodes` table
  
* `p_prefix_nodes_get_subtree_by_node_id(node_id INT UNSIGNED)`

  Get subtree by a node id
  
* `p_prefix_nodes_move_old_paths_after_update(node_old_parent_id INT UNSIGNED,node_new_parent_id INT UNSIGNED)`

  Update paths when move a node to a new parent node
  
* `p_prefix_nodes_delete_nodes(node_id INT UNSIGNED, is_deleted INT UNSIGNED)`

  Hidden or show nodes from subtree, explains as following:

  - First `call p_prefix_nodes_get_subtree_by_node_id(6)` get a HARDWARE subtree,
  - Second `call p_prefix_nodes_delete_nodes(6, 0)` to hidden subtree,
  - Third `call p_prefix_nodes_get_subtree_by_node_id(6)` again get HARDWARE subtree, but this time the HARDWARE subtree was disappeared
  - Fourth `call p_prefix_nodes_delete_nodes(6, 1)` show HARDWARE subtree

Files
-----

* `sql/tables.sql`

  Create tables.

* `sql/sample_data.sql`

  Some insert statements for testing
  

