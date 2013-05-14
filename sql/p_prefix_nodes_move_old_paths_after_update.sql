DELIMITER $$

USE `_category`$$

DROP PROCEDURE IF EXISTS `p_prefix_nodes_move_old_paths_after_update`$$

CREATE DEFINER = `root` @`localhost` PROCEDURE `p_prefix_nodes_move_old_paths_after_update` (
    `node_old_parent_id` INT UNSIGNED,
    `node_new_parent_id` INT UNSIGNED
) COMMENT 'Update paths when parent_id column changed'
BEGIN
    -- References:
    -- http://www.mysqlperformanceblog.com/2011/02/14/moving-subtrees-in-closure-table/
    -- The store procedure is used to update paths informations when the value of parent_id columns is changed (when move a node to a new parent)
    -- If parent_id has chanaged
    -- 1. Delete the paths between moved node and old ancestors
    -- 2. Add the paths between moved node and new ancestors
    DELETE
        a
    FROM
        `prefix_nodes_paths` AS a
        JOIN `prefix_nodes_paths` AS d
            ON a.`descendant_id` = d.`descendant_id`
        LEFT JOIN `prefix_nodes_paths` AS x
            ON x.`ancestor_id` = d.`ancestor_id`
            AND x.`descendant_id` = a.`ancestor_id`
    WHERE d.`ancestor_id` = `node_old_parent_id`
        AND x.`ancestor_id` IS NULL ;
    -- Add the node to its new parent
    INSERT `prefix_nodes_paths` (
        `ancestor_id`,
        `descendant_id`,
        `path_length`
    )
    SELECT
        supertree.`ancestor_id`,
        subtree.`descendant_id`,
        supertree.`path_length` + subtree.`path_length` + 1
    FROM
        `prefix_nodes_paths` AS supertree
        JOIN `prefix_nodes_paths` AS subtree
    WHERE subtree.`ancestor_id` = `node_old_parent_id`
        AND supertree.`descendant_id` = `node_new_parent_id` ;
END$$

DELIMITER ;
