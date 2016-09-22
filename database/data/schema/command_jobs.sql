CREATE TABLE `command_jobs` (
  `idcommand_jobs` int(11) NOT NULL AUTO_INCREMENT,
  `timestamp` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `state` varchar(7) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'success; pending; failed',
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `commands_idcommands` int(11) NOT NULL,
  `device_iddevice` int(11) NOT NULL,
  PRIMARY KEY (`idcommand_jobs`),
  KEY `fk_command_jobs_commands1` (`commands_idcommands`),
  KEY `fk_command_jobs_device1` (`device_iddevice`),
  CONSTRAINT `fk_command_jobs_commands1` FOREIGN KEY (`commands_idcommands`) REFERENCES `commands` (`idcommands`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_command_jobs_device1` FOREIGN KEY (`device_iddevice`) REFERENCES `device` (`iddevice`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='if status == failed then we increase timestamp 15 minutes'