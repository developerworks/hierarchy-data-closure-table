DELIMITER $$

USE `_category`$$

DROP PROCEDURE IF EXISTS `p_prefix_nodes_get_subtree_by_node_id`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_prefix_nodes_get_subtree_by_node_id`(
    node_id INT UNSIGNED
) COMMENT 'Query all descendants nodes by a node id, return as a result set'
BEGIN
    SELECT
        d.`id`,
        d.`is_deleted`,
        d.`parent_id`,
        CONCAT(
            REPEAT('-', p.`path_length`),
            d.`name`
        ) AS tree,
        p.`path_length`,
        GROUP_CONCAT(
            crumbs.`ancestor_id` SEPARATOR ','
        ) AS breadcrumbs
    FROM
        `prefix_nodes` AS d
        JOIN `prefix_nodes_paths` AS p
            ON d.`id` = p.`descendant_id`
        JOIN `prefix_nodes_paths` AS crumbs
            ON crumbs.`descendant_id` = p.`descendant_id`
    WHERE p.`ancestor_id` = `node_id`
        AND d.`is_deleted` = 0
    GROUP BY d.`id`
    ORDER BY breadcrumbs ;
END$$

DELIMITER ;
