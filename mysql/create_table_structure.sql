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
