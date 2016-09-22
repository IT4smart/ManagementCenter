CREATE TABLE `messages` (
  `idmessages` int(11) NOT NULL AUTO_INCREMENT,
  `level` varchar(5) COLLATE utf8_unicode_ci NOT NULL COMMENT 'DEBUG; INFO; WARN; ERR; WEB (only for text in the webfrontend)',
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`idmessages`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci