DROP TABLE IF EXISTS `locales`;
CREATE TABLE `locales` (
  `idlocales` varchar(5) COLLATE utf8_unicode_ci NOT NULL COMMENT 'that''s what we insert: https://en.wikipedia.org/wiki/Locale#POSIX_platforms',
  `locale_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`idlocales`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;