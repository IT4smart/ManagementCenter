DROP TABLE IF EXISTS `user_rights_to_usergroups`;
CREATE TABLE `user_rights_to_usergroups` (
  `iduser_rights_to_usergroups` int(11) NOT NULL AUTO_INCREMENT,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `user_rights_iduser_rights` int(11) NOT NULL,
  `usergroups_idusergroups` int(11) NOT NULL,
  PRIMARY KEY (`iduser_rights_to_usergroups`),
  KEY `fk_user_rights_to_usergroups_user_rights1` (`user_rights_iduser_rights`),
  KEY `fk_user_rights_to_usergroups_usergroups1` (`usergroups_idusergroups`),
  CONSTRAINT `fk_user_rights_to_usergroups_user_rights1` FOREIGN KEY (`user_rights_iduser_rights`) REFERENCES `user_rights` (`iduser_rights`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_rights_to_usergroups_usergroups1` FOREIGN KEY (`usergroups_idusergroups`) REFERENCES `usergroups` (`idusergroups`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='assigne any user right to a usergroup';