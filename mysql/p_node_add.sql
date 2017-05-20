DELIMITER $$

USE `hierarchy_data`$$

DROP PROCEDURE IF EXISTS `p_node_add`$$

CREATE PROCEDURE `p_node_add`(
  param_node_new_id    INT UNSIGNED,
  param_node_parent_id INT UNSIGNED
)
COMMENT 'Adding new paths prefix_nodes_paths table'
BEGIN
  -- Update paths information
  INSERT INTO `prefix_nodes_paths` (
    `ancestor_id`,
    `descendant_id`,
    `path_length`
  )
  SELECT
    `ancestor_id`,
    `param_node_new_id`,
    `path_length` + 1
  FROM
    `prefix_nodes_paths`
  WHERE `descendant_id` = `param_node_parent_id`
  UNION
  ALL
  SELECT
    `param_node_new_id`,
    `param_node_new_id`,
    0 ;
END$$

DELIMITER ;
