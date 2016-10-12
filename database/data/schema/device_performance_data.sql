CREATE TABLE `device_performance_data` (
  `iddevice_performance_data` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'fqdn; os_version; last_boot; cpu; ram; gateway; dns; ntp; state',
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value_date` datetime DEFAULT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `device_iddevice` int(11) NOT NULL,
  PRIMARY KEY (`iddevice_performance_data`),
  KEY `fk_device_performance_data_device1` (`device_iddevice`),
  CONSTRAINT `fk_device_performance_data_device1` FOREIGN KEY (`device_iddevice`) REFERENCES `device` (`iddevice`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='we can collacte all data from device frequently'