DROP TABLE IF EXISTS `prefix_nodes_paths`;
DROP TABLE IF EXISTS `prefix_nodes`;

CREATE TABLE `prefix_nodes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `order` int(11) DEFAULT NULL,
  `name` varchar(128) NOT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  `user_id` int(11) NOT NULL,
  `user_type` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `parent_id` (`parent_id`),
  KEY `name` (`name`),
  CONSTRAINT `prefix_nodes_ibfk1` FOREIGN KEY (`parent_id`) REFERENCES `prefix_nodes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `prefix_nodes_paths` (
  `ancestor_id` int(11) NOT NULL,
  `descendant_id` int(11) NOT NULL,
  `path_length` int(11) NOT NULL,
  PRIMARY KEY (`ancestor_id`,`descendant_id`),
  KEY `descendant_id` (`descendant_id`),
  CONSTRAINT `prefix_nodes_paths_ibfk_1` FOREIGN KEY (`ancestor_id`)   REFERENCES `prefix_nodes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `prefix_nodes_paths_ibfk_2` FOREIGN KEY (`descendant_id`) REFERENCES `prefix_nodes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DELIMITER $$

USE `hierarchy_data`$$

DROP TRIGGER IF EXISTS `trigger_add_node`$$

CREATE
    TRIGGER `trigger_add_node` AFTER INSERT ON `prefix_nodes`
    FOR EACH ROW BEGIN
    CALL p_node_add(NEW.`id`, NEW.`parent_id`);
END;
$$

DELIMITER ;


DELIMITER $$

USE `hierarchy_data`$$

DROP TRIGGER IF EXISTS `trigger_move_node`$$

CREATE TRIGGER `trigger_move_node` AFTER UPDATE ON `prefix_nodes`
  FOR EACH ROW BEGIN
  IF NOT OLD.`parent_id` <=> NEW.`parent_id` THEN
    -- http://www.mysqlperformanceblog.com/2011/02/14/moving-subtrees-in-closure-table/
    -- in the example, when change node D's parent to B.
    -- its sql has only D & B. so I think it should currentNode.id& newParent.id
    CALL p_node_move(NEW.`id`, NEW.`parent_id`);
  END IF;

  IF OLD.`is_deleted` != NEW.`is_deleted` THEN
      CALL p_node_hide(NEW.`parent_id`, NEW.`is_deleted`);
  END IF;
END;
$$

DELIMITER ;


DELIMITER $$

USE `hierarchy_data`$$

DROP PROCEDURE IF EXISTS `p_get_tree`$$

CREATE PROCEDURE `p_get_tree`(
    node_id INT UNSIGNED
) COMMENT 'Query all descendants nodes by a node id, return as a result set'
BEGIN
  SELECT
    node.`id`,
    node.`is_deleted`,
    node.`parent_id`,
    CONCAT(
        REPEAT('-', path.`path_length`),
        node.`name`
    ) AS name,
    path.`path_length`,
    GROUP_CONCAT(
        crumbs.`ancestor_id` SEPARATOR ','
    ) AS breadcrumbs
  FROM
    `prefix_nodes` AS node
    JOIN `prefix_nodes_paths` AS path
      ON node.`id` = path.`descendant_id`
    JOIN `prefix_nodes_paths` AS crumbs
      ON crumbs.`descendant_id` = path.`descendant_id`
  WHERE path.`ancestor_id` = `node_id`
    AND node.`is_deleted` = 0
  GROUP BY node.`id`
  ORDER BY breadcrumbs ;
END$$

DELIMITER ;


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


DELIMITER $$

USE `hierarchy_data`$$

DROP PROCEDURE IF EXISTS `p_node_hide`$$

CREATE PROCEDURE `p_node_hide` (
  `node_id` INT UNSIGNED,
  `deleted` INT UNSIGNED
) COMMENT 'Delete a node and its descendant nodes(update is_deleted = 1)'
BEGIN
  UPDATE
    `prefix_nodes` AS d
    JOIN `prefix_nodes_paths` AS p
      ON d.`id` = p.`descendant_id`
    JOIN `prefix_nodes_paths` AS crumbs
      ON crumbs.`descendant_id` = p.`descendant_id` SET d.`is_deleted` = deleted
  WHERE p.`ancestor_id` = node_id;
END $$

DELIMITER ;


DELIMITER $$

USE `hierarchy_data`$$

DROP PROCEDURE IF EXISTS `p_node_move`$$

CREATE PROCEDURE `p_node_move` (
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


INSERT INTO `prefix_nodes` VALUES(1, NULL, NULL, 'ROOT',DEFAULT, 0, 0);
INSERT INTO `prefix_nodes` VALUES(2, 1, NULL, 'C0',DEFAULT, 0, 3);
INSERT INTO `prefix_nodes` VALUES(3, 1, NULL, 'B0',DEFAULT, 0, 2);




INSERT INTO `prefix_nodes` VALUES(NULL, 3, NULL, 'A1',DEFAULT, 0, 1);
INSERT INTO `prefix_nodes` VALUES(NULL, 3, NULL, 'A2',DEFAULT, 0, 1);
INSERT INTO `prefix_nodes` VALUES(NULL, 3, NULL, 'A3',DEFAULT, 0, 1);
INSERT INTO `prefix_nodes` VALUES(NULL, 3, NULL, 'A4',DEFAULT, 0, 1);
INSERT INTO `prefix_nodes` VALUES(NULL, 3, NULL, 'A5',DEFAULT, 0, 1);
INSERT INTO `prefix_nodes` VALUES(NULL, 3, NULL, 'A6',DEFAULT, 0, 1);
INSERT INTO `prefix_nodes` VALUES(NULL, 3, NULL, 'A7',DEFAULT, 0, 1);
INSERT INTO `prefix_nodes` VALUES(NULL, 3, NULL, 'A8',DEFAULT, 0, 1);
INSERT INTO `prefix_nodes` VALUES(NULL, 3, NULL, 'A9',DEFAULT, 0, 1);

