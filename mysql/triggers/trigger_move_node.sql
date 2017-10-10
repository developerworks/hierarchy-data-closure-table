DELIMITER $$

USE `hierarchy_data`$$

DROP TRIGGER IF EXISTS `trigger_move_node`$$

CREATE TRIGGER `trigger_move_node` AFTER UPDATE ON `prefix_nodes`
  FOR EACH ROW BEGIN
  IF OLD.`parent_id` != NEW.`parent_id` THEN
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
