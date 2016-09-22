CREATE TABLE `users_to_usergroups` (
  `idusers_to_usergroups` int(11) NOT NULL AUTO_INCREMENT,
  `users_idusers` int(11) NOT NULL,
  `usergroups_idusergroups` int(11) NOT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`idusers_to_usergroups`),
  KEY `fk_users_to_usergroups_usergroups1` (`usergroups_idusergroups`),
  KEY `fk_users_to_usergroups_users1` (`users_idusers`),
  CONSTRAINT `fk_users_to_usergroups_usergroups1` FOREIGN KEY (`usergroups_idusergroups`) REFERENCES `usergroups` (`idusergroups`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_users_to_usergroups_users1` FOREIGN KEY (`users_idusers`) REFERENCES `users` (`idusers`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci