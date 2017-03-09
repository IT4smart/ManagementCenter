DROP TABLE IF EXISTS `device_groups`;
CREATE TABLE `device_groups` (
  `iddevice_groups` int(11) NOT NULL AUTO_INCREMENT,
  `device_group_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `state` int(1) DEFAULT '1' COMMENT '0 --> disabled\n1 --> enabled',
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`iddevice_groups`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;