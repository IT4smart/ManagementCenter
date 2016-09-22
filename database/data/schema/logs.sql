CREATE TABLE `logs` (
  `idlogs` int(11) NOT NULL AUTO_INCREMENT,
  `device_name` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `messages_idmessages` int(11) NOT NULL,
  `values` text COLLATE utf8_unicode_ci COMMENT '''#'' to seperate different values.',
  `status_code` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`idlogs`),
  KEY `fk_logs_messages1` (`messages_idmessages`),
  KEY `idx_logs_messages_idmessages` (`messages_idmessages`),
  CONSTRAINT `fk_logs_messages1` FOREIGN KEY (`messages_idmessages`) REFERENCES `messages` (`idmessages`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Logging all actions'