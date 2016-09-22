CREATE TABLE `commands` (
  `idcommands` int(11) NOT NULL AUTO_INCREMENT,
  `command_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `command` text COLLATE utf8_unicode_ci NOT NULL,
  `interval` int(11) DEFAULT '0' COMMENT 'in minutes',
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`idcommands`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='different commands'