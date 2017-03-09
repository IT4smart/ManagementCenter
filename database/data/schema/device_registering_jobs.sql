DROP TABLE IF EXISTS `device_registering_jobs`;
CREATE TABLE `device_registering_jobs` (
  `iddevice_registering_jobs` int(11) NOT NULL AUTO_INCREMENT,
  `timestamp` datetime NOT NULL,
  `state` varchar(45) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'new' COMMENT 'new, working, done, error, wait_resp (waiting for response)',
  `mac` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `hostname` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `group` varchar(45) COLLATE utf8_unicode_ci DEFAULT 'Default group',
  `device_type` varchar(45) COLLATE utf8_unicode_ci DEFAULT 'TC light',
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`iddevice_registering_jobs`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;