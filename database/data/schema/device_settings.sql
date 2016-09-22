CREATE TABLE `device_settings` (
  `iddevice_settings` int(11) NOT NULL AUTO_INCREMENT,
  `messages_idmessages` int(11) NOT NULL,
  `categorie_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL COMMENT 'Citrix; RDP; Network; Security; System',
  `setting_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `comment` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`iddevice_settings`),
  KEY `fk_device_settings_messages1` (`messages_idmessages`),
  CONSTRAINT `fk_device_settings_messages1` FOREIGN KEY (`messages_idmessages`) REFERENCES `messages` (`idmessages`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='here we store all settings which are pushed to the thinclien'