DELIMITER $$

USE `_category`$$

DROP TRIGGER /*!50032 IF EXISTS */ `prefix_nodes_move_old_paths_after_update`$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `prefix_nodes_move_old_paths_after_update` AFTER UPDATE ON `prefix_nodes` 
    FOR EACH ROW BEGIN
    IF OLD.`parent_id` != NEW.`parent_id` THEN
        --http://www.mysqlperformanceblog.com/2011/02/14/moving-subtrees-in-closure-table/
        --in the example, when change node D's parent to B.
        --its sql has only D & B. so I think it should currentNode.id& newParent.id
        CALL p_prefix_nodes_move_old_paths_after_update(NEW.`id`, NEW.`parent_id`);
    END IF;

    IF OLD.`is_deleted` != NEW.`is_deleted` THEN
        CALL p_prefix_nodes_delete_nodes_after_update(NEW.`parent_id`);
    END IF;
END;
$$

DELIMITER ;
