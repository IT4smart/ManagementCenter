CREATE TABLE `scheduled_task_jobs` (
  `idscheduled_task_jobs` int(11) NOT NULL AUTO_INCREMENT,
  `scheduled_tasks_idscheduled_tasks` int(11) NOT NULL,
  `timestamp` datetime NOT NULL,
  `last_run` datetime DEFAULT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`idscheduled_task_jobs`),
  KEY `fk_scheduled_task_jobs_scheduled_tasks1` (`scheduled_tasks_idscheduled_tasks`),
  CONSTRAINT `fk_scheduled_task_jobs_scheduled_tasks1` FOREIGN KEY (`scheduled_tasks_idscheduled_tasks`) REFERENCES `scheduled_tasks` (`idscheduled_tasks`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci