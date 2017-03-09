DROP TABLE IF EXISTS `scheduled_tasks`;
CREATE TABLE `scheduled_tasks` (
  `idscheduled_tasks` int(11) NOT NULL AUTO_INCREMENT,
  `task_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `description` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(45) COLLATE utf8_unicode_ci NOT NULL COMMENT 'activated, deactivated',
  `start_date` datetime NOT NULL,
  `end_date` datetime DEFAULT NULL,
  `minute` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `hour` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `day_of_month` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `month` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `weekday` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `commands_idcommands` int(11) NOT NULL,
  `next_run` datetime DEFAULT NULL COMMENT 'insert datetime for the next run of the specific task',
  PRIMARY KEY (`idscheduled_tasks`),
  KEY `fk_scheduled_tasks_commands1_idx` (`commands_idcommands`),
  CONSTRAINT `fk_scheduled_tasks_commands1` FOREIGN KEY (`commands_idcommands`) REFERENCES `commands` (`idcommands`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;