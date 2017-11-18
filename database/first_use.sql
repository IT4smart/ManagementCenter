--
-- Author: Raphael Lekies <raphael.lekies@it4s.eu>
-- Version: 0.1
--
-- Description: Script to fill database with content for the first use.
--

-- Insert all relevant commands
LOCK TABLES `commands` WRITE;
/*!40000 ALTER TABLE `commands` DISABLE KEYS */;
INSERT IGNORE INTO `commands` VALUES 
(1,'Restart','Neustart des Geräts','sudo reboot',0,now(),'admin',now(),'admin'),
(2,'Device state','Geräte Status ermitteln','get device state',5,now(),'admin',now(),'admin'),
(3,'Uptime','Uptime','get uptime',10,now(),'admin',now(),'admin'),
(4,'Package Data','Get information of all installed packages','get_package_data',60,now(),'admin',now(),'admin'),
(5,'Register','Add an unknown device','register_device',0,now(),'admin',now(),'admin'),
(6,'Device Data','Get information about the device','get_device_data',10,now(),'admin',now(),'admin'),
(7,'Shutdown','Shutdown the device','shutdown',0,now(),'admin',now(),'admin')
(8, 'Update device setting', 'Update the device setting', 'update_device_setting', 0, now(), 'admin', now(), 'admin');
/*!40000 ALTER TABLE `commands` ENABLE KEYS */;
UNLOCK TABLES;


-- Create a device group to put all new devices on
LOCK TABLES `device_groups` WRITE;
/*!40000 ALTER TABLE `device_groups` DISABLE KEYS */;
INSERT IGNORE INTO `device_groups` VALUES 
(1,'Default Group','Default group for all ThinClients',1,now(),'admin',now(),'admin');
/*!40000 ALTER TABLE `device_groups` ENABLE KEYS */;
UNLOCK TABLES;


-- Import the different device types of IT4S
LOCK TABLES `device_types` WRITE;
/*!40000 ALTER TABLE `device_types` DISABLE KEYS */;
INSERT IGNORE INTO `device_types` VALUES 
(1,'TC light','ThinClient light version',1,now(),'admin',now(),'admin'),
(2, 'TC multimedia', 'ThinClient with multimedia support', 1, now(), 'admin', now(), 'admin');
/*!40000 ALTER TABLE `device_types` ENABLE KEYS */;
UNLOCK TABLES;


-- Configure logs

-- Insert locales
LOCK TABLES `locales` WRITE;
/*!40000 ALTER TABLE `locales` DISABLE KEYS */;
INSERT IGNORE INTO `locales` VALUES 
('de_DE','german',now(),'admin', now(), 'admin');
/*!40000 ALTER TABLE `locales` ENABLE KEYS */;
UNLOCK TABLES;

-- Insert messages
LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT IGNORE INTO `messages` VALUES 
(1,'INFO',now(),'admin',now(),'admin'),
(2,'ERR',now(),'admin',now(),'admin'),
(3,'DEBUG',now(),'admin',now(),'admin'),
(5,'INFO',now(),'admin',now(),'admin'),
(6,'ERR',now(),'admin',now(),'admin'),
(7,'DEBUG',now(),'admin',now(),'admin'),
(8,'INFO',now(),'admin',now(),'admin'),
(9,'ERR',now(),'admin',now(),'admin'),
(10,'DEBUG',now(),'admin',now(),'admin'),
(12,'INFO',now(),'admin',now(),'admin'),
(13,'ERR',now(),'admin',now(),'admin'),
(14,'DEBUG',now(),'admin',now(),'admin'),
(15,'INFO',now(),'admin',now(),'admin'),
(16,'ERR',now(),'admin',now(),'admin'),
(17,'DEBUG',now(),'admin',now(),'admin'),
(18,'INFO',now(),'admin',now(),'admin'),
(19,'ERR',now(),'admin',now(),'admin'),
(20,'DEBUG',now(),'admin',now(),'admin'),
(21,'INFO',now(),'admin',now(),'admin'),
(22,'ERR',now(),'admin',now(),'admin'),
(23,'DEBUG',now(),'admin',now(),'admin'),
(27,'INFO',now(),'admin',now(),'admin'),
(28,'ERR',now(),'admin',now(),'admin'),
(29,'DEBUG',now(),'admin',now(),'admin'),
(30,'INFO',now(),'admin',now(),'admin'),
(31,'ERR',now(),'admin',now(),'admin'),
(32,'DEBUG',now(),'admin',now(),'admin'),
(33,'INFO',now(),'admin',now(),'admin'),
(34,'ERR',now(),'admin',now(),'admin'),
(35,'DEBUG',now(),'admin',now(),'admin'),
(36,'INFO',now(),'admin',now(),'admin'),
(37,'ERR',now(),'admin',now(),'admin'),
(38,'DEBUG',now(),'admin',now(),'admin'),
(39,'INFO',now(),'admin',now(),'admin'),
(40,'INFO',now(),'admin',now(),'admin'),
(41,'DEBUG',now(),'admin',now(),'admin'),
(42,'ERR',now(),'admin',now(),'admin'),
(43,'INFO',now(),'admin',now(),'admin'),
(44,'DEBUG',now(),'admin',now(),'admin'),
(45,'ERR',now(),'admin',now(),'admin'),
(46,'INFO',now(),'admin',now(),'admin'),
(47,'ERR',now(),'admin',now(),'admin'),
(48,'DEBUG',now(),'admin',now(),'admin'),
(49,'INFO',now(),'admin',now(),'admin'),
(50,'ERR',now(),'admin',now(),'admin'),
(51,'DEBUG',now(),'admin',now(),'admin'),
(52,'INFO',now(),'admin',now(),'admin'),
(53,'ERR',now(),'admin',now(),'admin'),
(54,'DEBUG',now(),'admin',now(),'admin'),
(55,'INFO',now(),'admin',now(),'admin'),
(56,'ERR',now(),'admin',now(),'admin'),
(57,'DEBUG',now(),'admin',now(),'admin'),
(58,'INFO',now(),'admin',now(),'admin'),
(59,'ERR',now(),'admin',now(),'admin'),
(60,'DEBUG',now(),'admin',now(),'admin'),
(61,'INFO',now(),'admin',now(),'admin'),
(62,'ERR',now(),'admin',now(),'admin'),
(63,'DEBUG',now(),'admin',now(),'admin'),
(64,'INFO',now(),'admin',now(),'admin'),
(65,'ERR',now(),'admin',now(),'admin'),
(66,'DEBUG',now(),'admin',now(),'admin'),
(67,'WARN',now(),'admin',now(),'admin'),
(68,'DEBUG',now(),'admin',now(),'admin'),
(69,'ERR',now(),'admin',now(),'admin'),
(70,'DEBUG',now(),'admin',now(),'admin'),
(71,'INFO',now(),'admin',now(),'admin'),
(72,'INFO',now(),'admin',now(),'admin'),
(73,'INFO',now(),'admin',now(),'admin'),
(74,'INFO',now(),'admin',now(),'admin'),
(75,'WARN',now(),'admin',now(),'admin'),
(76,'DEBUG',now(),'admin',now(),'admin'),
(77,'DEBUG',now(),'admin',now(),'admin'),
(78,'ERR',now(),'admin',now(),'admin'),
(79,'DEBUG',now(),'admin',now(),'admin'),
(80,'INFO',now(),'admin',now(),'admin'),
(81,'ERR',now(),'admin',now(),'admin'),
(82,'DEBUG',now(),'admin',now(),'admin'),
(83,'INFO',now(),'admin',now(),'admin'),
(84,'ERR',now(),'admin',now(),'admin'),
(85,'INFO',now(),'admin',now(),'admin'),
(86,'WARN',now(),'admin',now(),'admin'),
(87,'ERR',now(),'admin',now(),'admin'),
(88,'DEBUG',now(),'admin',now(),'admin'),
(89,'INFO',now(),'admin',now(),'admin'),
(90,'ERR',now(),'admin',now(),'admin'),
(91,'DEBUG',now(),'admin',now(),'admin');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

-- Insert translations
LOCK TABLES `translations` WRITE;
/*!40000 ALTER TABLE `translations` DISABLE KEYS */;
INSERT IGNORE INTO `translations` VALUES 
(1,1,'de_DE','Wir haben den Benutzer # erfolgreich angelegt.',now(),'',now(),''),
(2,2,'de_DE','Es ist ein Fehler aufgetreten den Benutzer # zu erstellen.',now(),'admin',now(),'admin'),
(3,3,'de_DE','Es ist ein Fehler aufgetreten den Benutzer # zu erstellen. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(6,5,'de_DE','Das Passwort des Benutzers # wurde erfolgreich aktualisiert.',now(),'admin',now(),'admin'),
(7,6,'de_DE','Es ist ein Fehler aufgetreten beim aktualisieren des Passworts für den Benutzer #.',now(),'admin',now(),'admin'),
(8,7,'de_DE','Es ist ein Fehler aufgetreten beim aktualisieren des Passworts für den Benutzer #. Fehler = #, Nachricht = #.',now(),'admin',now(),'admin'),
(9,8,'de_DE','Wir haben das Gerät # erfolgreich angelegt.',now(),'admin',now(),'admin'),
(10,9,'de_DE','Es ist ein Fehler aufgetreten beim Anlegen des Geräts #.',now(),'admin',now(),'admin'),
(11,10,'de_DE','Es ist ein Fehler aufgetreten beim Anlegen des Geräts #. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(14,12,'de_DE','Wir haben die Gerätegruppe # erfolgreich angelegt.',now(),'admin',now(),'admin'),
(15,13,'de_DE','Es ist ein Fehler aufgetreten beim Erstellen der Gerätegruppe #.',now(),'admin',now(),'admin'),
(16,14,'de_DE','Es ist ein Fehler aufgetreten beim Erstellen der Gerätegruppe #. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(17,15,'de_DE','Wir haben das Geräteprofil # erfolgreich angelegt.',now(),'admin',now(),'admin'),
(18,16,'de_DE','Es ist ein Fehler aufgetreten beim Anlegen des Geräteprofils #.',now(),'admin',now(),'admin'),
(19,17,'de_DE','Es ist ein Fehler aufgetreten beim Anlegen des Geräteprofils #. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(20,18,'de_DE','Wir haben das Geräteprofil # erfolgreich zur Gerätegruppe # hinzugefügt.',now(),'admin',now(),'admin'),
(21,19,'de_DE','Es ist ein Fehler aufgetreten beim hinzufügen des Geräteprofils # zur Gerätegruppe #.',now(),'admin',now(),'admin'),
(22,20,'de_DE','Es ist ein Fehler aufgetreten beim hinzufügen des Geräteprofils # zur Gerätegruppe #. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(23,21,'de_DE','Wir haben das Gerät # erfolgreich zur Gerätegruppe # hinzugefügt.',now(),'admin',now(),'admin'),
(24,22,'de_DE','Es ist ein Fehler aufgetreten beim Hinzufügen des Geräts # zur Gerätegruppe #.',now(),'admin',now(),'admin'),
(25,23,'de_DE','Es ist ein Fehler aufgetreten beim Hinzufügen des Geräts # zur Gerätegruppe #. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(29,27,'de_DE','Wir haben die Aufgabe für das Kommando # erfolgreich aktualisiert. Neuer Status ist #',now(),'admin',now(),'admin'),
(30,29,'de_DE','Es ist ein Fehler aufgetreten beim Aktualisieren des Kommandos #. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(31,30,'de_DE','Wir haben das Gerät # erfolgreich aktualisiert.',now(),'admin',now(),'admin'),
(32,31,'de_DE','Es ist ein Fehler augetreten beim aktualisieren des Geräts #.',now(),'admin',now(),'admin'),
(33,32,'de_DE','Es ist ein Fehler augetreten beim aktualisieren des Geräts #. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(34,33,'de_DE','Wir haben das Geräteprofil # erfolgreich aktualisiert.',now(),'admin',now(),'admin'),
(35,34,'de_DE','Es ist ein Fehler aufgetreten beim aktualisieren des Geräteprofils #.',now(),'admin',now(),'admin'),
(36,35,'de_DE','Es ist ein Fehler aufgetreten beim aktualisieren des Geräteprofils #. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(37,36,'de_DE','Wir haben das Gerät # erfolgreich aus der Gerätegruppe # entfernt.',now(),'admin',now(),'admin'),
(38,37,'de_DE','Es ist ein Fehler aufgetreten das Gerät # aus der Gerätegruppe # zu entfernen.',now(),'admin',now(),'admin'),
(39,38,'de_DE','Es ist ein Fehler aufgetreten das Gerät # aus der Gerätegruppe # zu entfernen. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(40,39,'de_DE','Die Informationen zum Gerät # wurden erfolgreich aktualisiert.',now(),'admin',now(),'admin'),
(41,40,'de_DE','Die Einstellung # im Profile # für die Kategorie # wurde mit dem Wert # erfolgreich angelegt.',now(),'admin',now(),'admin'),
(42,41,'de_DE','Es ist ein Fehler aufgetreten die Einstellung # im Profile # für die Kategorie # mit dem Wert # anzulegen.',now(),'admin',now(),'admin'),
(43,42,'de_DE','Es ist ein Fehler aufgetreten die Einstellung # im Profile # für die Kategorie # mit dem Wert # anzulegen. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(44,43,'de_DE','Die Einstellung # in der Kategorie # für das Profil # wurde erfolgreich entfernt.',now(),'admin',now(),'admin'),
(45,44,'de_DE','Es ist ein Fehler aufgetreten beim entfernen der Einstellung # in der Kategorie # für das Profil #.',now(),'admin',now(),'admin'),
(46,45,'de_DE','Es ist ein Fehler aufgetreten beim entfernen der Einstellung # in der Kategorie # für das Profil #. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(47,46,'de_DE','Es konnte erfolgreich die Greätegruppe # aktualisiert werden.',now(),'admin',now(),'admin'),
(48,47,'de_DE','Es ist ein Fehler aufgetreten beim Aktualisieren der Gerätegruppe #',now(),'admin',now(),'admin'),
(49,48,'de_DE','Es ist ein Fehler aufgetreten beim Aktualisieren der Gerätegruppe #. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(50,49,'de_DE','Wir haben das Geräteprofil # erfolgreich aus der Gerätegruppe # entfernt',now(),'admin',now(),'admin'),
(51,50,'de_DE','Es ist ein Fehler aufgetreten das Geräteprofil # aus der Gerätegruppe # zu entfernen.',now(),'admin',now(),'admin'),
(52,51,'de_DE','Es ist ein Fehler aufgetreten das Geräteprofil # aus der Gerätegruppe # zu entfernen. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(53,52,'de_DE','Die E-Mail Adresse des Benutzers # wurde erfolgreich aktualisiert.',now(),'admin',now(),'admin'),
(54,53,'de_DE','Es ist ein Fehler aufgetreten die E-Mail Adresse des Benutzers # zu aktualisieren.',now(),'admin',now(),'admin'),
(55,54,'de_DE','Es ist ein Fehler aufgetreten die E-Mail Adresse des Benutzers # zu aktualisieren. Fehler = #, Nachricht = #.',now(),'admin',now(),'admin'),
(56,55,'de_DE','Die Benutzergruppe # wurde erfolgreich angelegt.',now(),'admin',now(),'admin'),
(57,56,'de_DE','Es ist ein Fehler aufgetreten beim erstellen der Benutzergruppe #.',now(),'admin',now(),'admin'),
(58,57,'de_DE','Es ist ein Fehler aufgetreten beim erstellen der Benutzergruppe #. Fehler = #, Nachricht = #.',now(),'admin',now(),'admin'),
(59,58,'de_DE','Für den Benutzer # konnte die Benutzergruppe von # auf # erfolgreich geändert werden.',now(),'admin',now(),'admin'),
(60,59,'de_DE','Es ist ein Fehler aufgetreten beim Aktualisieren der Zuordnung des Benutzers # zur neuen Benutzergruppe.',now(),'admin',now(),'admin'),
(61,60,'de_DE','Es ist ein Fehler aufgetreten beim Aktualisieren der Zuordnung des Benutzers # zur neuen Benutzergruppe. Fehler = #, Nachricht = #.',now(),'admin',now(),'admin'),
(62,61,'de_DE','Der Wert # des Geräts # wurde auf # gesetzt',now(),'admin',now(),'admin'),
(63,62,'de_DE','Der Status für das Gerät # konnte nicht geändert werden.',now(),'admin',now(),'admin'),
(64,63,'de_DE','Der Status für das Gerät # konnte nicht geändert werden. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(65,65,'de_DE','Der Auftrag # konnte für das Gerät # nicht angelegt werden.',now(),'admin',now(),'admin'),
(66,66,'de_DE','Der Auftrag # konnte für das Gerät # nicht angelegt werden. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(67,64,'de_DE','Der Auftrag # für das Gerät # wurde angelegt.',now(),'admin',now(),'admin'),
(68,28,'de_DE','Die Aufgabe mit der ID # für für das Kommando # konnte nicht aktualisiert werden. ',now(),'admin',now(),'admin'),
(69,67,'de_DE','Die Aufgabe mit der ID # für das Kommando # konnte auf dem Gerät # nicht ausgeführt werden. ',now(),'admin',now(),'admin'),
(70,68,'de_DE','Die Aufgabe # meldet folgenden Fehler: #',now(),'admin',now(),'admin'),
(71,69,'de_DE','Die Aufgabe # konnte nicht aktualisiert werden.',now(),'admin',now(),'admin'),
(72,70,'de_DE','Die Aufgabe # konnte nicht aktualisiert werden. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(73,71,'de_DE','Die Aufgabe # läuft gerade auf dem Gerät #',now(),'admin',now(),'admin'),
(74,72,'de_DE','Der Status des Geräts # wurde von online in offline geändert.',now(),'admin',now(),'admin'),
(75,73,'de_DE','Der Status des Geräts # wird überprüft. Die Differenz beträgt im moment # Minuten.',now(),'admin',now(),'admin'),
(76,74,'de_DE','Das Gerät # hat folgende Uptime: #',now(),'admin',now(),'admin'),
(77,75,'de_DE','Die Uptime für das Gerät # konnte nicht ermittelt werden.',now(),'admin',now(),'admin'),
(78,76,'de_DE','Die Uptime für das Gerät # konnte nicht ermittelt werden. Fehler = #, Nachricht = #.',now(),'admin',now(),'admin'),
(79,77,'de_DE','Das Paket # mit der Version # wurde für das Gerät # hinzugefügt.',now(),'admin',now(),'admin'),
(80,78,'de_DE','Es konnte das Paket # nicht hinzugefügt werden für das Gerät #.',now(),'admin',now(),'admin'),
(81,79,'de_DE','Es konnte das Paket # nicht hinzugefügt werden für das Gerät #. Fehler = #, Nachricht = #.',now(),'admin',now(),'admin'),
(82,80,'de_DE','Das Gerät mit der MAC # und dem Gerätenamen # wurde zur Registrierung hinzugefügt.',now(),'admin',now(),'admin'),
(83,81,'de_DE','Ein Gerät konnte nicht zur Registrierung hinzugefügt werden. #',now(),'admin',now(),'admin'),
(84,82,'de_DE','Ein Gerät konnte nicht zur Registrierung hinzugefügt werden. #. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(85,83,'de_DE','Das Gerät mit der MAC # und dem Gerätenamen # wird nun versucht zu registrieren.',now(),'admin',now(),'admin'),
(86,84,'de_DE','Das Gerät mit der MAC # und dem Gerätenamen # konnte nicht registriert werden.',now(),'admin',now(),'admin'),
(87,85,'de_DE','Das Gerät mit der MAC # und dem Gerätenamen # wurde registriert.',now(),'admin',now(),'admin'),
(88,86,'de_DE','Das Gerät mit der MAC # hat den folgenden Status.',now(),'admin',now(),'admin'),
(89,87,'de_DE','Das Gerät mit der MAC # konnte nicht angelegt werden da es bereits angelegt ist.',now(),'admin',now(),'admin'),
(90,88,'de_DE','Das Gerät mit der MAC # und dem Gerätenamen # konnte nicht registriert werden. Fehler = #, Nachricht = #',now(),'admin',now(),'admin'),
(91,89,'de_DE','Die geplante Aufgabe # für den Auftrag # wurde hinzugefügt`',now(),'admin',now(),'admin'),
(92,90,'de_DE','Die geplante Aufgabe # für den Auftrag # konnte nicht hinzugefügt werden.',now(),'admin',now(),'admin'),(93,91,'de_DE','Die geplante Aufgabe # für den Auftrag # konnte nicht hinzugefügt werden. Fehler = #, Nachricht = #',now(),'admin',now(),'admin');
/*!40000 ALTER TABLE `translations` ENABLE KEYS */;
UNLOCK TABLES;


-- Import the general user rights
LOCK TABLES `user_rights` WRITE;
/*!40000 ALTER TABLE `user_rights` DISABLE KEYS */;
INSERT IGNORE INTO `user_rights` VALUES 
(1,'show_device','Device',now(),'admin',now(),'admin'),
(2,'edit_device','Device',now(),'admin',now(),'admin'),
(3,'create_device','Device',now(),'admin',now(),'admin'),
(4,'delete_device','Device',now(),'admin',now(),'admin'),
(5,'show_profile','Profile',now(),'admin',now(),'admin'),
(6,'edit_profile','Profile',now(),'admin',now(),'admin'),
(7,'create_profile','Profile',now(),'admin',now(),'admin'),
(8,'delete_profile','Profile',now(),'admin',now(),'admin'),
(9,'show_profilegroup','Profilegroup',now(),'admin',now(),'admin'),
(10,'edit_profilegroup','Profilegroup',now(),'admin',now(),'admin'),
(11,'create_profilegroup','Profilegroup',now(),'admin',now(),'admin'),
(12,'delete_profilegroup','Profilegroup',now(),'admin',now(),'admin'),
(13,'show_user','User',now(),'admin',now(),'admin'),
(14,'edit_user','User',now(),'admin',now(),'admin'),
(15,'create_user','User',now(),'admin',now(),'admin'),
(16,'delete_user','User',now(),'admin',now(),'admin'),
(17,'show_usergroup','Usergroup',now(),'admin',now(),'admin'),
(18,'edit_usergroup','Usergroup',now(),'admin',now(),'admin'),
(19,'create_usergroup','Usergroup',now(),'admin',now(),'admin'),
(20,'delete_usergroup','Usergroup',now(),'admin',now(),'admin'),
(21,'show_report','Report',now(),'admin',now(),'admin'),
(22,'edit_report','Report',now(),'admin',now(),'admin'),
(23,'create_report','Report',now(),'admin',now(),'admin'),
(24,'delete_report','Report',now(),'admin',now(),'admin'),
(25,'show_right','Right',now(),'admin',now(),'admin'),
(26,'edit_right','Right',now(),'admin',now(),'admin');
/*!40000 ALTER TABLE `user_rights` ENABLE KEYS */;
UNLOCK TABLES;

-- Import initial usergroups
LOCK TABLES `usergroups` WRITE;
/*!40000 ALTER TABLE `usergroups` DISABLE KEYS */;
INSERT IGNORE INTO `usergroups` VALUES 
(1,'Administrators','All users for administration',now(),'admin',now(),'');
/*!40000 ALTER TABLE `usergroups` ENABLE KEYS */;
UNLOCK TABLES;

-- Import initial user to usergroup
LOCK TABLES `users_to_usergroups` WRITE;
/*!40000 ALTER TABLE `users_to_usergroups` DISABLE KEYS */;
INSERT IGNORE INTO `users_to_usergroups` VALUES (1,1,1,now(),'admin',now(),'admin');
/*!40000 ALTER TABLE `users_to_usergroups` ENABLE KEYS */;
UNLOCK TABLES;

-- import initial admin user
LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT IGNORE INTO `users` VALUES (1,'admin','$2y$10$V7X8.DoKEkY1J3jA3zJxPO.Bn2Zp.nBZQpoMVK/ePTHwrLMvRunYu',NULL,'app/upload/profile_default.png',0,now(),'admin',now(),'admin');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;


-- Create a mysql user 
CREATE USER 'it4s-query-user'@'localhost' IDENTIFIED BY '!123456!';

-- Grant user the minimum permissions
GRANT DELETE ON verwaltungskonsole_v1.* TO 'it4s-query-user'@'localhost';
GRANT EXECUTE ON verwaltungskonsole_v1.* TO 'it4s-query-user'@'localhost';
GRANT INSERT ON verwaltungskonsole_v1.* TO 'it4s-query-user'@'localhost';
GRANT SELECT ON verwaltungskonsole_v1.* TO 'it4s-query-user'@'localhost';
GRANT TRIGGER ON verwaltungskonsole_v1.* TO 'it4s-query-user'@'localhost';
GRANT UPDATE ON verwaltungskonsole_v1.* TO 'it4s-query-user'@'localhost';

-- Reload the privileges
FLUSH PRIVILEGES;
