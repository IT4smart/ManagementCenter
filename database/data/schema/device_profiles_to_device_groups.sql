CREATE TABLE `device_profiles_to_device_groups` (
  `iddevice_profiles_to_device_groups` int(11) NOT NULL AUTO_INCREMENT,
  `device_profiles_iddevice_profiles` int(11) NOT NULL,
  `device_groups_iddevice_groups` int(11) NOT NULL,
  `order` int(2) DEFAULT '1',
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`iddevice_profiles_to_device_groups`),
  KEY `fk_device_profiles_to_device_groups_device_profiles1` (`device_profiles_iddevice_profiles`),
  KEY `fk_device_profiles_to_device_groups_device_groups1` (`device_groups_iddevice_groups`),
  CONSTRAINT `fk_device_profiles_to_device_groups_device_groups1` FOREIGN KEY (`device_groups_iddevice_groups`) REFERENCES `device_groups` (`iddevice_groups`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_device_profiles_to_device_groups_device_profiles1` FOREIGN KEY (`device_profiles_iddevice_profiles`) REFERENCES `device_profiles` (`iddevice_profiles`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci