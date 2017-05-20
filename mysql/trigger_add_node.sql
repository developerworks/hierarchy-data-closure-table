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
