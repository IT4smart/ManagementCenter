DROP TABLE IF EXISTS `scheduled_tasks_to_device_groups`;
CREATE TABLE `scheduled_tasks_to_device_groups` (
  `idscheduled_tasks_to_device_groups` int(11) NOT NULL AUTO_INCREMENT,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `scheduled_tasks_idscheduled_tasks` int(11) NOT NULL,
  `device_groups_iddevice_groups` int(11) NOT NULL,
  PRIMARY KEY (`idscheduled_tasks_to_device_groups`),
  KEY `fk_scheduled_tasks_to_device_groups_scheduled_tasks1_idx` (`scheduled_tasks_idscheduled_tasks`),
  KEY `fk_scheduled_tasks_to_device_groups_device_groups1_idx` (`device_groups_iddevice_groups`),
  CONSTRAINT `fk_scheduled_tasks_to_device_groups_device_groups1` FOREIGN KEY (`device_groups_iddevice_groups`) REFERENCES `device_groups` (`iddevice_groups`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_scheduled_tasks_to_device_groups_scheduled_tasks1` FOREIGN KEY (`scheduled_tasks_idscheduled_tasks`) REFERENCES `scheduled_tasks` (`idscheduled_tasks`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;