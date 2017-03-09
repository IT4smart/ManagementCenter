DROP TABLE IF EXISTS `commands`;
CREATE TABLE `commands` (
  `idcommands` int(11) NOT NULL AUTO_INCREMENT,
  `command_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `command` text COLLATE utf8_unicode_ci NOT NULL,
  `interval` int(11) DEFAULT '0' COMMENT 'in minutes',
  `scheduled_task` int(11) NOT NULL DEFAULT '0',
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) CHARACTER SET utf8 NOT NULL COMMENT '0 --> this command is not for scheduled tasks\n1 --> this command is for scheduled tasks',
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`idcommands`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='different commands';