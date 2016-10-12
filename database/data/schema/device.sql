CREATE TABLE `device` (
  `iddevice` int(11) NOT NULL AUTO_INCREMENT,
  `device_types_iddevice_types` int(11) NOT NULL,
  `device_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `mac_address` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `serialnumber` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `device_photo` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'path to image. it''s stored as a file on server.',
  `state` varchar(45) COLLATE utf8_unicode_ci DEFAULT 'pending' COMMENT 'activated, pending, deactivated',
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`iddevice`),
  UNIQUE KEY `device_name_UNIQUE` (`device_name`),
  KEY `idx_device_name` (`device_name`),
  KEY `fk_device_device_types1` (`device_types_iddevice_types`),
  CONSTRAINT `fk_device_device_types1` FOREIGN KEY (`device_types_iddevice_types`) REFERENCES `device_types` (`iddevice_types`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci