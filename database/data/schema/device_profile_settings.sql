DROP TABLE IF EXISTS `device_profile_settings`;
CREATE TABLE `device_profile_settings` (
  `iddevice_profile_settings` int(11) NOT NULL AUTO_INCREMENT,
  `device_profiles_iddevice_profiles` int(11) NOT NULL,
  `setting_categorie_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL COMMENT 'Citrix; RDP; Network; Security',
  `setting_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `value` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`iddevice_profile_settings`),
  UNIQUE KEY `unique_index` (`device_profiles_iddevice_profiles`,`setting_categorie_name`,`setting_name`),
  KEY `fk_device_profile_settings_device_profiles1` (`device_profiles_iddevice_profiles`),
  KEY `idx_setting_categorie_name` (`setting_categorie_name`),
  KEY `idx_setting_name` (`setting_name`),
  CONSTRAINT `fk_device_profile_settings_device_profiles1` FOREIGN KEY (`device_profiles_iddevice_profiles`) REFERENCES `device_profiles` (`iddevice_profiles`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;