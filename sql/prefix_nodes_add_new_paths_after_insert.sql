DELIMITER $$

USE `_category`$$

DROP TRIGGER /*!50032 IF EXISTS */ `prefix_nodes_add_new_paths_after_insert`$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `prefix_nodes_add_new_paths_after_insert` AFTER INSERT ON `prefix_nodes`
    FOR EACH ROW BEGIN
    CALL p_prefix_nodes_add_new_paths_after_insert(NEW.`id`, NEW.`parent_id`);
END;
$$

DELIMITER ;
