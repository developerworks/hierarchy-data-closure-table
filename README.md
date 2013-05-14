Closure Table
=============

This is a mysql store procedure and trigger implementation of closure table in RDBMS about hierarchy data model.

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

* `p_prefix_nodes_add_new_paths_after_insert`
* `_prefix_nodes_get_subtree_by_node_id`
* `p_prefix_nodes_move_old_paths_after_update`
