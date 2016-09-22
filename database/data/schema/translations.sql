CREATE TABLE `translations` (
  `idtranslations` int(11) NOT NULL AUTO_INCREMENT,
  `messages_idmessages` int(11) NOT NULL,
  `locales_idlocales` varchar(5) COLLATE utf8_unicode_ci NOT NULL,
  `text_translation` text COLLATE utf8_unicode_ci NOT NULL COMMENT 'text in the translated language',
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`idtranslations`),
  KEY `fk_translations_locales1` (`locales_idlocales`),
  KEY `fk_translations_messages1` (`messages_idmessages`),
  CONSTRAINT `fk_translations_locales1` FOREIGN KEY (`locales_idlocales`) REFERENCES `locales` (`idlocales`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_translations_messages1` FOREIGN KEY (`messages_idmessages`) REFERENCES `messages` (`idmessages`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci