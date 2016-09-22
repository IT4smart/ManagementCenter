CREATE TABLE `devices_to_device_groups` (
  `iddevices_to_device_groups` int(11) NOT NULL AUTO_INCREMENT,
  `device_iddevice` int(11) NOT NULL,
  `device_groups_iddevice_groups` int(11) NOT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`iddevices_to_device_groups`),
  KEY `fk_devices_to_device_groups_device1` (`device_iddevice`),
  KEY `fk_devices_to_device_groups_device_groups1` (`device_groups_iddevice_groups`),
  CONSTRAINT `fk_devices_to_device_groups_device1` FOREIGN KEY (`device_iddevice`) REFERENCES `device` (`iddevice`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_devices_to_device_groups_device_groups1` FOREIGN KEY (`device_groups_iddevice_groups`) REFERENCES `device_groups` (`iddevice_groups`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci