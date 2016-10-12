CREATE TABLE `device_packages` (
  `iddevice_packages` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `version` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `upgrade` int(11) DEFAULT '0' COMMENT '1 --> has an upgrade\n0 --> no upgrade available',
  `device_iddevice` int(11) NOT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`iddevice_packages`),
  KEY `fk_device_packages_device1_idx` (`device_iddevice`),
  CONSTRAINT `fk_device_packages_device1` FOREIGN KEY (`device_iddevice`) REFERENCES `device` (`iddevice`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci