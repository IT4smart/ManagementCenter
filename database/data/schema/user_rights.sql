DROP TABLE IF EXISTS `user_rights`;
CREATE TABLE `user_rights` (
  `iduser_rights` int(11) NOT NULL AUTO_INCREMENT,
  `user_right_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `user_right_group` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`iduser_rights`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;