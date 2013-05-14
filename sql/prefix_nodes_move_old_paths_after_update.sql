DELIMITER $$

USE `_category`$$

DROP TRIGGER /*!50032 IF EXISTS */ `prefix_nodes_move_old_paths_after_update`$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `prefix_nodes_move_old_paths_after_update` AFTER UPDATE ON `prefix_nodes` 
    FOR EACH ROW BEGIN
    CALL p_prefix_nodes_move_old_paths_after_update(OLD.`parent_id`, NEW.`parent_id`);
END;
$$

DELIMITER ;