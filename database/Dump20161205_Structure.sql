CREATE DATABASE  IF NOT EXISTS `verwaltungskonsole_v1` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;
USE `verwaltungskonsole_v1`;
-- MySQL dump 10.13  Distrib 5.7.12, for Win64 (x86_64)
--
-- Host: 192.168.178.39    Database: verwaltungskonsole_v1
-- ------------------------------------------------------
-- Server version	5.6.27-0ubuntu0.14.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `command_jobs`
--

DROP TABLE IF EXISTS `command_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `command_jobs` (
  `idcommand_jobs` int(11) NOT NULL AUTO_INCREMENT,
  `timestamp` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `payload` mediumtext COLLATE utf8_unicode_ci,
  `state` varchar(7) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'success; pending; failed',
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `commands_idcommands` int(11) NOT NULL,
  `device_iddevice` int(11) NOT NULL,
  PRIMARY KEY (`idcommand_jobs`),
  KEY `fk_command_jobs_commands1` (`commands_idcommands`),
  KEY `fk_command_jobs_device1_idx` (`device_iddevice`),
  CONSTRAINT `fk_command_jobs_commands1` FOREIGN KEY (`commands_idcommands`) REFERENCES `commands` (`idcommands`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_command_jobs_device1` FOREIGN KEY (`device_iddevice`) REFERENCES `device` (`iddevice`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='if status == failed then we increase timestamp 15 minutes';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER command_jobs_AUDE AFTER UPDATE ON command_jobs FOR EACH ROW
BEGIN

declare new_time datetime;

set new_time = DATE_ADD(now(), INTERVAL 15 MINUTE);

IF NEW.state = 'failed' THEN
 BEGIN
    update command_jobs set modify_timestamp = now(), modify_user = 'trigger', timestamp = new_time
    where idcommand_jobs = old.idcommand_jobs;
 END;
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `commands`
--

DROP TABLE IF EXISTS `commands`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `commands` (
  `idcommands` int(11) NOT NULL AUTO_INCREMENT,
  `command_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `command` text COLLATE utf8_unicode_ci NOT NULL,
  `interval` int(11) DEFAULT '0' COMMENT 'in minutes',
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`idcommands`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='different commands';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `verwaltungskonsole_v1`.`commands_AFTER_INSERT` AFTER INSERT ON `commands` FOR EACH ROW
BEGIN
	declare v_id int;
	DECLARE no_more_rows BOOLEAN;
	declare commands_cursor cursor for select `iddevice` from device where `state` = 'activated';
    
    
    -- Declare 'handlers' for exceptions
	DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET no_more_rows = TRUE;

	open commands_cursor;
    
    get_data: LOOP
		FETCH commands_cursor INTO v_id;
        
        IF no_more_rows THEN
			LEAVE get_data;
		END IF;
        
        IF NEW.`interval` > 0 THEN
			call sp_insert_command_jobs(@out, NEW.`idcommands`, v_id, NEW.`interval`, '', 'trigger');
		END IF;
        
	END LOOP get_data;
    
    close commands_cursor;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `device`
--

DROP TABLE IF EXISTS `device`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `device` (
  `iddevice` int(11) NOT NULL AUTO_INCREMENT,
  `device_types_iddevice_types` int(11) NOT NULL,
  `device_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `mac_address` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `serialnumber` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `device_photo` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'path to image. it''s stored as a file on server.',
  `state` varchar(45) COLLATE utf8_unicode_ci DEFAULT 'pending' COMMENT 'activated, pending, deactivated',
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`iddevice`),
  UNIQUE KEY `device_name_UNIQUE` (`device_name`),
  KEY `idx_device_name` (`device_name`),
  KEY `fk_device_device_types1` (`device_types_iddevice_types`),
  CONSTRAINT `fk_device_device_types1` FOREIGN KEY (`device_types_iddevice_types`) REFERENCES `device_types` (`iddevice_types`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `verwaltungskonsole_v1`.`device_AFTER_UPDATE` AFTER UPDATE ON `device` FOR EACH ROW
BEGIN

	declare v_idcommand int;
    declare v_interval int;
    
	-- insert jobs to collect data
	declare no_more_rows boolean;
	declare command_cursor cursor for select `idcommands`, `interval` from `commands` where `interval` > 0;
        
	-- Declare 'handlers' for exceptions
	DECLARE CONTINUE HANDLER FOR NOT FOUND
	SET no_more_rows = TRUE;

	IF NEW.`state` = 'activated' THEN
		-- insert tempalte for performance data
		insert into device_performance_data (`name`, `value`, `value_date`, `insert_timestamp`, `insert_user`, `modify_timestamp`, `modify_user`, `device_iddevice`)
        VALUES ('state', 'offline', null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
			('last_check', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('uptime', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('net_ip', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('net_speed', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('net_type', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('net_subnetmask', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('net_gateway', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('net_dns1', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('net_dns2', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('cpu_family', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('cpu_speed', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('cpu_cores', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('memory_total', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('memory_free', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('architecture', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('kernel_version', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice);
            
		open command_cursor;
        
        get_data: LOOP
			FETCH command_cursor INTO v_idcommand, v_interval;
        
			IF no_more_rows THEN
				LEAVE get_data;
			END IF;
        
			call sp_insert_command_jobs(@out, v_idcommand, OLD.iddevice, v_interval, '', 'trigger');
		END LOOP get_data;
    
		close command_cursor;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `device_groups`
--

DROP TABLE IF EXISTS `device_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `device_packages`
--

DROP TABLE IF EXISTS `device_packages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `device_packages` (
  `iddevice_packages` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `version` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `upgrade` int(11) DEFAULT '0' COMMENT '1 --> has an upgrade\n0 --> no upgrade available',
  `device_iddevice` int(11) NOT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`iddevice_packages`),
  KEY `fk_device_packages_device1_idx` (`device_iddevice`),
  CONSTRAINT `fk_device_packages_device1` FOREIGN KEY (`device_iddevice`) REFERENCES `device` (`iddevice`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `device_performance_data`
--

DROP TABLE IF EXISTS `device_performance_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `device_performance_data` (
  `iddevice_performance_data` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'fqdn; os_version; last_boot; cpu; ram; gateway; dns; ntp; state',
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value_date` datetime DEFAULT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `device_iddevice` int(11) NOT NULL,
  PRIMARY KEY (`iddevice_performance_data`),
  KEY `fk_device_performance_data_device1` (`device_iddevice`),
  CONSTRAINT `fk_device_performance_data_device1` FOREIGN KEY (`device_iddevice`) REFERENCES `device` (`iddevice`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='we can collacte all data from device frequently';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `device_profile_settings`
--

DROP TABLE IF EXISTS `device_profile_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `device_profiles`
--

DROP TABLE IF EXISTS `device_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `device_profiles` (
  `iddevice_profiles` int(11) NOT NULL AUTO_INCREMENT,
  `profile_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `state` int(1) DEFAULT '1' COMMENT '0 --> disabled\n1 --> enabled',
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`iddevice_profiles`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `device_profiles_to_device_groups`
--

DROP TABLE IF EXISTS `device_profiles_to_device_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `device_profiles_to_device_groups` (
  `iddevice_profiles_to_device_groups` int(11) NOT NULL AUTO_INCREMENT,
  `device_profiles_iddevice_profiles` int(11) NOT NULL,
  `device_groups_iddevice_groups` int(11) NOT NULL,
  `order` int(2) DEFAULT '1',
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`iddevice_profiles_to_device_groups`),
  KEY `fk_device_profiles_to_device_groups_device_profiles1` (`device_profiles_iddevice_profiles`),
  KEY `fk_device_profiles_to_device_groups_device_groups1` (`device_groups_iddevice_groups`),
  CONSTRAINT `fk_device_profiles_to_device_groups_device_groups1` FOREIGN KEY (`device_groups_iddevice_groups`) REFERENCES `device_groups` (`iddevice_groups`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_device_profiles_to_device_groups_device_profiles1` FOREIGN KEY (`device_profiles_iddevice_profiles`) REFERENCES `device_profiles` (`iddevice_profiles`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `device_registering_jobs`
--

DROP TABLE IF EXISTS `device_registering_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `verwaltungskonsole_v1`.`device_registering_jobs_AFTER_UPDATE` AFTER UPDATE ON `device_registering_jobs` FOR EACH ROW
BEGIN

	declare v_message text;
	set v_message = (SELECT CONCAT(OLD.`mac`, '#', OLD.`hostname`));

	IF NEW.`state` = 'working' THEN
		call sp_insert_log_entry('', 83, v_message, 'success', 'trigger');
	ELSEIF NEW.`state` = 'error' THEN
        call sp_insert_log_entry('', 84, v_message, 'failed', 'trigger');
	ELSEIF NEW.`state` = 'done' THEN
		call sp_insert_log_entry('', 85, v_message, 'success', 'trigger');
	ELSEIF NEW.`state` = 'wait_resp' THEN
		call sp_insert_log_entry('', 85, v_message, 'success', 'trigger');
	ELSE
		set v_message = (SELECT CONCAT(OLD.`mac`, '#', OLD.`state`));
        call sp_insert_log_entry('', 86, v_message, 'success', 'trigger');
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `device_settings`
--

DROP TABLE IF EXISTS `device_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `device_settings` (
  `iddevice_settings` int(11) NOT NULL AUTO_INCREMENT,
  `messages_idmessages` int(11) NOT NULL,
  `categorie_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL COMMENT 'Citrix; RDP; Network; Security; System',
  `setting_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `comment` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`iddevice_settings`),
  KEY `fk_device_settings_messages1` (`messages_idmessages`),
  CONSTRAINT `fk_device_settings_messages1` FOREIGN KEY (`messages_idmessages`) REFERENCES `messages` (`idmessages`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='here we store all settings which are pushed to the thinclient';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `device_types`
--

DROP TABLE IF EXISTS `device_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `device_types` (
  `iddevice_types` int(11) NOT NULL AUTO_INCREMENT,
  `device_type_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `state` int(1) DEFAULT '1' COMMENT '0 --> disabled\n1 --> enabled',
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`iddevice_types`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Our different products';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `devices_to_device_groups`
--

DROP TABLE IF EXISTS `devices_to_device_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `devices_to_device_groups` (
  `iddevices_to_device_groups` int(11) NOT NULL AUTO_INCREMENT,
  `device_iddevice` int(11) NOT NULL,
  `device_groups_iddevice_groups` int(11) NOT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`iddevices_to_device_groups`),
  KEY `fk_devices_to_device_groups_device1` (`device_iddevice`),
  KEY `fk_devices_to_device_groups_device_groups1` (`device_groups_iddevice_groups`),
  CONSTRAINT `fk_devices_to_device_groups_device1` FOREIGN KEY (`device_iddevice`) REFERENCES `device` (`iddevice`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_devices_to_device_groups_device_groups1` FOREIGN KEY (`device_groups_iddevice_groups`) REFERENCES `device_groups` (`iddevice_groups`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `locales`
--

DROP TABLE IF EXISTS `locales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `locales` (
  `idlocales` varchar(5) COLLATE utf8_unicode_ci NOT NULL COMMENT 'that''s what we insert: https://en.wikipedia.org/wiki/Locale#POSIX_platforms',
  `locale_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`idlocales`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `logs`
--

DROP TABLE IF EXISTS `logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `logs` (
  `idlogs` int(11) NOT NULL AUTO_INCREMENT,
  `device_name` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `messages_idmessages` int(11) NOT NULL,
  `values` text COLLATE utf8_unicode_ci COMMENT '''#'' to seperate different values.',
  `status_code` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`idlogs`),
  KEY `fk_logs_messages1` (`messages_idmessages`),
  KEY `idx_logs_messages_idmessages` (`messages_idmessages`),
  CONSTRAINT `fk_logs_messages1` FOREIGN KEY (`messages_idmessages`) REFERENCES `messages` (`idmessages`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Logging all actions';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `messages` (
  `idmessages` int(11) NOT NULL AUTO_INCREMENT,
  `level` varchar(5) COLLATE utf8_unicode_ci NOT NULL COMMENT 'DEBUG; INFO; WARN; ERR; WEB (only for text in the webfrontend)',
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`idmessages`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scheduled_tasks`
--

DROP TABLE IF EXISTS `scheduled_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scheduled_tasks` (
  `idscheduled_tasks` int(11) NOT NULL AUTO_INCREMENT,
  `task_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `description` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(45) COLLATE utf8_unicode_ci NOT NULL COMMENT 'activated, deactivated',
  `start_date` datetime NOT NULL,
  `end_date` datetime DEFAULT NULL,
  `minute` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `hour` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `day_of_month` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `month` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `weekday` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `commands_idcommands` int(11) NOT NULL,
  PRIMARY KEY (`idscheduled_tasks`),
  KEY `fk_scheduled_tasks_commands1_idx` (`commands_idcommands`),
  CONSTRAINT `fk_scheduled_tasks_commands1` FOREIGN KEY (`commands_idcommands`) REFERENCES `commands` (`idcommands`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scheduled_tasks_to_device_groups`
--

DROP TABLE IF EXISTS `scheduled_tasks_to_device_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scheduled_tasks_to_device_groups` (
  `idscheduled_tasks_to_device_groups` int(11) NOT NULL AUTO_INCREMENT,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `scheduled_tasks_idscheduled_tasks` int(11) NOT NULL,
  `device_groups_iddevice_groups` int(11) NOT NULL,
  PRIMARY KEY (`idscheduled_tasks_to_device_groups`),
  KEY `fk_scheduled_tasks_to_device_groups_scheduled_tasks1_idx` (`scheduled_tasks_idscheduled_tasks`),
  KEY `fk_scheduled_tasks_to_device_groups_device_groups1_idx` (`device_groups_iddevice_groups`),
  CONSTRAINT `fk_scheduled_tasks_to_device_groups_device_groups1` FOREIGN KEY (`device_groups_iddevice_groups`) REFERENCES `device_groups` (`iddevice_groups`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_scheduled_tasks_to_device_groups_scheduled_tasks1` FOREIGN KEY (`scheduled_tasks_idscheduled_tasks`) REFERENCES `scheduled_tasks` (`idscheduled_tasks`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `translations`
--

DROP TABLE IF EXISTS `translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_rights`
--

DROP TABLE IF EXISTS `user_rights`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_rights` (
  `iduser_rights` int(11) NOT NULL AUTO_INCREMENT,
  `user_right_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `user_right_group` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`iduser_rights`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_rights_to_usergroups`
--

DROP TABLE IF EXISTS `user_rights_to_usergroups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usergroups`
--

DROP TABLE IF EXISTS `usergroups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usergroups` (
  `idusergroups` int(11) NOT NULL AUTO_INCREMENT,
  `group_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`idusergroups`),
  KEY `idx_user` (`insert_user`,`modify_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `idusers` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(90) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_photo` varchar(45) COLLATE utf8_unicode_ci DEFAULT 'app/upload/profile_default.png',
  `state` int(1) DEFAULT '1' COMMENT '0 --> disabeld\n1 --> enabled',
  `insert_timestamp` datetime NOT NULL,
  `insert_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `modify_timestamp` datetime NOT NULL,
  `modify_user` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`idusers`),
  UNIQUE KEY `username_UNIQUE` (`username`),
  KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users_to_usergroups`
--

DROP TABLE IF EXISTS `users_to_usergroups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `v_checked_devices`
--

DROP TABLE IF EXISTS `v_checked_devices`;
/*!50001 DROP VIEW IF EXISTS `v_checked_devices`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_checked_devices` AS SELECT 
 1 AS `device_name`,
 1 AS `iddevice`,
 1 AS `device_groups_iddevice_groups`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_command_jobs`
--

DROP TABLE IF EXISTS `v_command_jobs`;
/*!50001 DROP VIEW IF EXISTS `v_command_jobs`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_command_jobs` AS SELECT 
 1 AS `idcommand_jobs`,
 1 AS `timestamp`,
 1 AS `state`,
 1 AS `idcommands`,
 1 AS `command_name`,
 1 AS `description`,
 1 AS `command`,
 1 AS `interval`,
 1 AS `iddevice`,
 1 AS `device_name`,
 1 AS `mac_address`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_device_groups`
--

DROP TABLE IF EXISTS `v_device_groups`;
/*!50001 DROP VIEW IF EXISTS `v_device_groups`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_device_groups` AS SELECT 
 1 AS `iddevice_groups`,
 1 AS `device_group_name`,
 1 AS `description`,
 1 AS `state`,
 1 AS `insert_timestamp`,
 1 AS `insert_user`,
 1 AS `modify_timestamp`,
 1 AS `modify_user`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_device_performance_data`
--

DROP TABLE IF EXISTS `v_device_performance_data`;
/*!50001 DROP VIEW IF EXISTS `v_device_performance_data`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_device_performance_data` AS SELECT 
 1 AS `iddevice_performance_data`,
 1 AS `name`,
 1 AS `value`,
 1 AS `value_date`,
 1 AS `insert_timestamp`,
 1 AS `insert_user`,
 1 AS `modify_timestamp`,
 1 AS `modify_user`,
 1 AS `device_iddevice`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_device_profile_settings`
--

DROP TABLE IF EXISTS `v_device_profile_settings`;
/*!50001 DROP VIEW IF EXISTS `v_device_profile_settings`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_device_profile_settings` AS SELECT 
 1 AS `iddevice_profile_settings`,
 1 AS `device_profiles_iddevice_profiles`,
 1 AS `setting_categorie_name`,
 1 AS `setting_name`,
 1 AS `value`,
 1 AS `modify_timestamp`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_device_profiles`
--

DROP TABLE IF EXISTS `v_device_profiles`;
/*!50001 DROP VIEW IF EXISTS `v_device_profiles`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_device_profiles` AS SELECT 
 1 AS `iddevice_profiles`,
 1 AS `profile_name`,
 1 AS `description`,
 1 AS `state`,
 1 AS `insert_timestamp`,
 1 AS `insert_user`,
 1 AS `modify_timestamp`,
 1 AS `modify_user`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_device_registering_jobs`
--

DROP TABLE IF EXISTS `v_device_registering_jobs`;
/*!50001 DROP VIEW IF EXISTS `v_device_registering_jobs`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_device_registering_jobs` AS SELECT 
 1 AS `iddevice_registering_jobs`,
 1 AS `timestamp`,
 1 AS `state`,
 1 AS `mac`,
 1 AS `hostname`,
 1 AS `group`,
 1 AS `device_type`,
 1 AS `insert_timestamp`,
 1 AS `insert_user`,
 1 AS `modify_timestamp`,
 1 AS `modify_user`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_device_settings`
--

DROP TABLE IF EXISTS `v_device_settings`;
/*!50001 DROP VIEW IF EXISTS `v_device_settings`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_device_settings` AS SELECT 
 1 AS `categorie_name`,
 1 AS `setting_name`,
 1 AS `text_translation`,
 1 AS `idlocales`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_device_summary_device_profiles`
--

DROP TABLE IF EXISTS `v_device_summary_device_profiles`;
/*!50001 DROP VIEW IF EXISTS `v_device_summary_device_profiles`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_device_summary_device_profiles` AS SELECT 
 1 AS `device_name`,
 1 AS `profile_name`,
 1 AS `modify_timestamp`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_device_to_device_group`
--

DROP TABLE IF EXISTS `v_device_to_device_group`;
/*!50001 DROP VIEW IF EXISTS `v_device_to_device_group`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_device_to_device_group` AS SELECT 
 1 AS `iddevice`,
 1 AS `device_name`,
 1 AS `mac_address`,
 1 AS `serialnumber`,
 1 AS `note`,
 1 AS `device_photo`,
 1 AS `d_state`,
 1 AS `iddevice_groups`,
 1 AS `device_group_name`,
 1 AS `description`,
 1 AS `dg_state`,
 1 AS `insert_timestamp`,
 1 AS `insert_user`,
 1 AS `modify_timestamp`,
 1 AS `modify_user`,
 1 AS `group_date_assigned`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_devices`
--

DROP TABLE IF EXISTS `v_devices`;
/*!50001 DROP VIEW IF EXISTS `v_devices`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_devices` AS SELECT 
 1 AS `iddevice`,
 1 AS `device_name`,
 1 AS `state`,
 1 AS `device_type_name`,
 1 AS `serialnumber`,
 1 AS `note`,
 1 AS `mac_address`,
 1 AS `photo`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_logs`
--

DROP TABLE IF EXISTS `v_logs`;
/*!50001 DROP VIEW IF EXISTS `v_logs`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_logs` AS SELECT 
 1 AS `device_name`,
 1 AS `status_code`,
 1 AS `modify_user`,
 1 AS `modify_timestamp`,
 1 AS `level`,
 1 AS `text_translation`,
 1 AS `idlocales`,
 1 AS `values`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_profile_to_device_group`
--

DROP TABLE IF EXISTS `v_profile_to_device_group`;
/*!50001 DROP VIEW IF EXISTS `v_profile_to_device_group`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_profile_to_device_group` AS SELECT 
 1 AS `iddevice_profiles`,
 1 AS `profile_name`,
 1 AS `dp_state`,
 1 AS `insert_timestamp`,
 1 AS `insert_user`,
 1 AS `modify_timestamp`,
 1 AS `modify_user`,
 1 AS `iddevice_groups`,
 1 AS `device_group_name`,
 1 AS `description`,
 1 AS `state`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_scheduled_tasks_jobs`
--

DROP TABLE IF EXISTS `v_scheduled_tasks_jobs`;
/*!50001 DROP VIEW IF EXISTS `v_scheduled_tasks_jobs`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_scheduled_tasks_jobs` AS SELECT 
 1 AS `idscheduled_tasks`,
 1 AS `task_name`,
 1 AS `description`,
 1 AS `state`,
 1 AS `start_date`,
 1 AS `end_date`,
 1 AS `minute`,
 1 AS `hour`,
 1 AS `day_of_month`,
 1 AS `month`,
 1 AS `weekday`,
 1 AS `device_iddevice`,
 1 AS `idcommands`,
 1 AS `command_name`,
 1 AS `command`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_user_rights_to_usergroups`
--

DROP TABLE IF EXISTS `v_user_rights_to_usergroups`;
/*!50001 DROP VIEW IF EXISTS `v_user_rights_to_usergroups`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_user_rights_to_usergroups` AS SELECT 
 1 AS `iduser_rights`,
 1 AS `user_right_name`,
 1 AS `user_right_group`,
 1 AS `idusergroups`,
 1 AS `group_name`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_users`
--

DROP TABLE IF EXISTS `v_users`;
/*!50001 DROP VIEW IF EXISTS `v_users`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_users` AS SELECT 
 1 AS `idusers`,
 1 AS `idusergroups`,
 1 AS `username`,
 1 AS `password`,
 1 AS `email`,
 1 AS `user_photo`,
 1 AS `user_timestamp`,
 1 AS `user_modify`,
 1 AS `group_name`,
 1 AS `description`,
 1 AS `usergroup_timestamp`,
 1 AS `usergroup_modify`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'verwaltungskonsole_v1'
--
/*!50106 SET @save_time_zone= @@TIME_ZONE */ ;
/*!50106 DROP EVENT IF EXISTS `check_device_state` */;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8 */ ;;
/*!50003 SET character_set_results = utf8 */ ;;
/*!50003 SET collation_connection  = utf8_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`%`*/ /*!50106 EVENT `check_device_state` ON SCHEDULE EVERY 1 MINUTE STARTS '2016-09-28 11:51:40' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    -- declare cursor
    declare v_state varchar(7);
    declare v_date datetime;
    declare v_diff int;
    declare v_deviceid int;
    declare v_device varchar(45);
    declare v_message varchar(200);
    DECLARE no_more_rows BOOLEAN;
    declare state_cursor cursor for 
    select `value`, `modify_timestamp`, `device_iddevice` from `v_device_performance_data` where `name` = 'state' and `value` = 'online';
	
    -- Declare 'handlers' for exceptions
	DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET no_more_rows = TRUE;
    
    open state_cursor;
    
    get_data: LOOP
		FETCH state_cursor INTO v_state, v_date, v_deviceid;
    
		IF no_more_rows THEN
			LEAVE get_data;
		END IF;
        
        set v_diff = (SELECT TIMESTAMPDIFF(MINUTE, v_date, now()));
		set v_device = (SELECT `device_name` from `device` where `iddevice` = v_deviceid);
        
        set v_message = (SELECT CONCAT(v_device, '#', v_diff));
        call sp_insert_log_entry('', 73, v_message, 'success', 'event_scheduler');
        
        IF v_diff > 5 THEN
			update `device_performance_data` set `value` = 'offline', `modify_timestamp` = now(), `modify_user` = 'event_scheduler' where `device_iddevice` = v_deviceid and `name` = 'state' and `device_iddevice` = v_deviceid;
			call sp_insert_log_entry('', 72, v_device, 'success', 'event_scheduler');
        END IF;
        
    END LOOP get_data;
    
    close state_cursor;

END */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
/*!50106 DROP EVENT IF EXISTS `register_device` */;;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8 */ ;;
/*!50003 SET character_set_results = utf8 */ ;;
/*!50003 SET collation_connection  = utf8_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`%`*/ /*!50106 EVENT `register_device` ON SCHEDULE EVERY 1 MINUTE STARTS '2016-10-08 21:57:41' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
	-- declare variables
    declare v_id int;
    declare v_mac varchar(45);
    declare v_temp_mac varchar(45);
    declare v_hostname varchar(45);
    declare v_group varchar(45);
    declare v_groupid int;
    declare v_device_type_id int;
	DECLARE no_more_rows BOOLEAN;
	declare device_cursor cursor for
	select `iddevice_registering_jobs`, `mac`, `hostname`, `group` from v_device_registering_jobs 
	where 1=1
	and `timestamp` <= now()
	and `state` = 'new';

	-- Declare 'handlers' for exceptions
	DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET no_more_rows = TRUE;

	open device_cursor;

	get_data: LOOP
		FETCH device_cursor INTO v_id, v_mac, v_hostname, v_group;
        
        IF no_more_rows THEN
			LEAVE get_data;
		END IF;
        
		-- set job to pending
		update device_registering_jobs set `state` = 'working', `modify_timestamp` = now(), `modify_user` = 'event_scheduler' where iddevice_registering_jobs = v_id;

		-- at first we should check if there is any other device with the same mac address
		set v_temp_mac = (SELECT `mac_address` FROM `v_devices` where `mac_address` = v_mac limit 1);

	IF v_temp_mac is null or v_temp_mac = '' THEN
        	set v_groupid = (SELECT iddevice_groups FROM device_groups where device_group_name = v_group);
        	set v_device_type_id = (select iddevice_types from device_types where device_type_name = (SELECT device_type from v_device_registering_jobs where iddevice_registering_jobs = v_id));
        	call sp_insert_device (@out, v_hostname, v_mac, '', '', v_device_type_id, v_groupid, '', 'event_scheduler');
    
		if @out = 1 then
			update device_registering_jobs set `state` = 'wait_resp', `modify_timestamp` = now(), `modify_user` = 'event_scheduler' where iddevice_registering_jobs = v_id;
		else
			update device_registering_jobs set `state` = 'error', `modify_timestamp` = now(), `modify_user` = 'event_scheduler' where iddevice_registering_jobs = v_id;
		end if;
	ELSE
		update device_registering_jobs set `state` = 'error', `modify_timestamp` = now(), `modify_user` = 'event_scheduler';
		call sp_insert_log_entry('', 87, v_mac, 'success', 'event_scheduler');
	END IF;
    
	END LOOP get_data;
    
    close device_cursor;


END */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
DELIMITER ;
/*!50106 SET TIME_ZONE= @save_time_zone */ ;

--
-- Dumping routines for database 'verwaltungskonsole_v1'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_device_profiles_to_device_groups` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_delete_device_profiles_to_device_groups`(OUT sp_result int, IN sp_idprofile int, IN sp_idgroup int, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2016
    -- ------------------------------------------------------------
    --  Created     : 20.02.2016
    --  Last change : 20.02.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, after the device
    --                profile delete from device group
    --
    --  20.02.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    
   
    -- declare variable
    declare v_message text;
    declare v_profile_name varchar(45);
    declare v_device_group varchar(45);
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;

    delete from device_profiles_to_device_groups where device_profiles_iddevice_profiles = sp_idprofile and device_groups_iddevice_groups = sp_idgroup;
    
    -- get data for logging
    set v_profile_name = (select profile_name from device_profiles where iddevice_profiles = sp_idprofile);
    set v_device_group = (select device_group_name from device_groups where iddevice_groups = sp_idgroup);
    
    
    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- prepare message for logging
        set v_message = (SELECT CONCAT(v_profile_name, '#', v_device_group));
        
        -- now we can write a log
        call sp_insert_log_entry('', '49', v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        set v_message = (SELECT CONCAT(v_profile_name, '#', v_device_group));
        call sp_insert_log_entry('', '50', v_message, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(v_profile_name, '#', v_device_group,'#', code, '#', msg));
        call sp_insert_log_entry('', '51', v_message, 'failed', sp_user);
    end if;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_device_profile_settings` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_delete_device_profile_settings`(OUT sp_result int, IN sp_iddevice_profile int, IN sp_categorie varchar(45), IN sp_setting_name varchar(45), IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 11.01.2016
    --  Last change : 11.01.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, after profile setting is 
    --                deleted
    --
    --  11.01.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------

    -- declare variable
    declare v_message text;
    declare vProfile varchar(45);
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;
        
	delete from device_profile_settings where device_profiles_iddevice_profiles = sp_iddevice_profile and setting_categorie_name = sp_categorie and setting_name = sp_setting_name;

	-- prepare for logging
	set vProfile = (SELECT profile_name from device_profiles where iddevice_profiles = sp_iddevice_profile);
        
    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- prepare values
        set v_message = (SELECT CONCAT(sp_setting_name, '#', sp_categorie, '#', vProfile));
        
        -- now we can write a log
        call sp_insert_log_entry('', '43', v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        set v_message = (SELECT CONCAT(sp_setting_name, '#', sp_categorie, '#', vProfile));
        call sp_insert_log_entry('', '44', v_message, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_setting_name, '#', sp_categorie, '#', vProfile, '#', code, '#', msg));
        call sp_insert_log_entry('', '45', v_message, 'failed', sp_user);
    end if;  
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_device_to_device_group` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_delete_device_to_device_group`(OUT sp_result int, IN sp_iddevice int, sp_iddevice_group int, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 09.12.2015
    --  Last change : 09.12.2015
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, after the device to 
    --                device group deleted. It's not possible to
    --                update such assingment.
    --
    --  09.12.2015  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    
   
    -- declare variable
    declare v_message text;
    declare v_device_name varchar(45);
    declare v_device_group varchar(45);
    DECLARE v_code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                v_code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;
        
    delete from `devices_to_device_groups` where `device_iddevice` = sp_iddevice and `device_groups_iddevice_groups` = sp_iddevice_group;
    
    -- get data for logs
    set v_device_name = (select `device_name` from `device` where `iddevice` = sp_iddevice);
    set v_device_group = (select `device_group_name` from `device_groups` where `iddevice_groups` = sp_iddevice_group);
    
    -- check whether the insert was successful
    IF v_code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- prepare message for logging
        set v_message = (SELECT CONCAT(v_device_name, '#', v_device_group));
        
        -- now we can write a log
        call sp_insert_log_entry(v_device_name, '36', v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        set v_message = (SELECT CONCAT(v_device_name, '#', v_device_group));
        call sp_insert_log_entry(v_device_name, '37', v_message, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(v_device_name, '#', v_device_group, '#', v_code, '#', msg));
        call sp_insert_log_entry(v_device_name, '38', v_message, 'failed', sp_user);
    end if;  
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_command_jobs` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_insert_command_jobs`(OUT sp_result int, IN sp_idcommands int, IN sp_iddevice int, IN sp_interval int, IN sp_payload text, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 04.12.2015
    --  Last change : 04.12.2015
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We update the command jobs and insert some
    --                logs.
    --
    --  04.12.2015  : Created
    --  12.08.2016	: Logging auf die aktuellste Version gebracht.
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------

    -- declare variable
    declare v_message text;
    declare vdevice_name varchar(45);
    declare vc_description text;
    declare vc_command_name varchar(45);
    declare v_lid int;
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;

	IF sp_interval > 0 then    
		insert into command_jobs (timestamp, state, payload, commands_idcommands, device_iddevice, insert_timestamp, insert_user, modify_timestamp, modify_user)
		values (DATE_ADD(now(), INTERVAL sp_interval MINUTE), NULL, sp_payload, sp_idcommands, sp_iddevice, now(), sp_user, now(), sp_user);
	ELSE
		insert into command_jobs (timestamp, state, payload, commands_idcommands, device_iddevice, insert_timestamp, insert_user, modify_timestamp, modify_user)
		values (now(), NULL, sp_payload, sp_idcommands, sp_iddevice, now(), sp_user, now(), sp_user);
    END IF;
    
	set v_lid = LAST_INSERT_ID();
        
	-- getting data
	set vdevice_name = (select device_name from v_command_jobs where idcommand_jobs = v_lid limit 1);
	set vc_command_name = (select command_name from v_command_jobs where idcommands = sp_idcommands limit 1);
    
    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
		set sp_result = 1;
        
        -- prepare message for logging
        set v_message = (SELECT CONCAT(vc_command_name, '#', vdevice_name));
        
        -- now we can write a log
        call sp_insert_log_entry('', 64, v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        set v_message = (SELECT CONCAT(vc_command_name, '#', vdevice_name));
        call sp_insert_log_entry('', 65, v_message, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(vc_command_name, '#', vdevice_name, '#', `code`, '#', msg));
        call sp_insert_log_entry('', 66, v_message, 'failed', sp_user);
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_device` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_insert_device`(OUT sp_result int, IN sp_device_name varchar(45), IN sp_mac_address varchar(45), IN sp_serialnumber varchar(45), IN sp_note text, IN sp_device_type int, IN sp_device_group int, IN sp_photo varchar(255), IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 07.12.2015
    --  Last change : 07.12.2015
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the device created
    --
    --  07.12.2015  : Created
    --	11.08.2016	: Add insert for command job
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    
   
    -- declare variable
    declare v_message text;
    declare lid int; -- last inserted id from table 'device'
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;
      
    -- insert device
    insert into device (device_types_iddevice_types, device_name, mac_address, serialnumber, note, device_photo, insert_timestamp, insert_user, modify_timestamp, modify_user)
    values (sp_device_type, sp_device_name, sp_mac_address, sp_serialnumber, sp_note, sp_photo, now(), sp_user, now(), sp_user);

    -- get latest inserted id from table 'device'
    set lid = last_insert_id();

    -- insert device and group
    insert into devices_to_device_groups (device_iddevice, device_groups_iddevice_groups, insert_timestamp, insert_user, modify_timestamp, modify_user)
    values (lid, sp_device_group, now(), sp_user, now(), sp_user);
    

    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- now we can write a log
        call sp_insert_log_entry('', '8', sp_device_name, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        call sp_insert_log_entry('', '9', sp_device_name, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_device_name, '#', code, '#', msg));
        call sp_insert_log_entry('', '10', v_message, 'failed', sp_user);
    end if;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_device_group` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_insert_device_group`(OUT sp_result int, IN sp_group_name varchar(45), IN sp_description text, IN sp_state int, sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 08.12.2015
    --  Last change : 08.12.2015
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the device group
    --                created
    --
    --  08.12.2015  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    
   
    -- declare variable
    declare v_message text;
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;
        
    insert into device_groups (device_group_name, description, state, insert_timestamp, insert_user, modify_timestamp, modify_user)
    values (sp_group_name, sp_description, sp_state, now(), sp_user, now(), sp_user);
    
    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- now we can write a log
        call sp_insert_log_entry('', '12', sp_group_name, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        call sp_insert_log_entry('', '13', sp_group_name, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_group_name, '#', code, '#', msg));
        call sp_insert_log_entry('', '14', v_message, 'failed', sp_user);
    end if;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_device_package_data` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_insert_device_package_data`(OUT sp_result int, IN sp_package_name varchar(45), IN sp_version varchar(45), IN sp_deviceid int, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2016
    -- ------------------------------------------------------------
    --  Created     : 30.09.2016
    --  Last change : 30.09.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert package details for every single device.
    --
    --  30.09.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------

    -- declare variable
    declare v_message text;
    declare v_device_name varchar(45);
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;

	IF EXISTS (select * from device_packages where `device_iddevice` = sp_deviceid and `name` = sp_package_name) THEN
		UPDATE device_packages set `version` = sp_version, `modify_timestamp` = now(), `modify_user` = sp_user where `device_iddevice` = sp_deviceid and `name` = sp_package_name;
	ELSE
		INSERT INTO device_packages(`name`, `version`, `device_iddevice`, `insert_timestamp`, `insert_user`, `modify_timestamp`, `modify_user`)
		VALUES (sp_package_name, sp_version, sp_deviceid, now(), sp_user, now(), sp_user);
    END IF;

    
    set v_device_name = (SELECT `device_name` FROM v_devices WHERE `iddevice` = sp_deviceid);
    
    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
		set sp_result = 1;
        
        -- prepare message for logging
        set v_message = (SELECT CONCAT(sp_package_name, '#', sp_version, '#', v_device_name));
        
        -- now we can write a log
        call sp_insert_log_entry('', 77, v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        set v_message = (SELECT CONCAT(sp_package_name, '#', v_device_name));
        call sp_insert_log_entry('', 78, v_message, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_package_name, '#', v_device_name, '#', `code`, '#', msg));
        call sp_insert_log_entry('', 79, v_message, 'failed', sp_user);
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_device_profiles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_insert_device_profiles`(OUT sp_result int, IN sp_profile_name varchar(45), IN sp_description text, IN sp_state int, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 09.12.2015
    --  Last change : 09.12.2015
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the device
    --                profile created
    --
    --  09.12.2015  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    
   
    -- declare variable
    declare v_message text;
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;
        
    insert into device_profiles (profile_name, description, state, insert_timestamp, insert_user, modify_timestamp, modify_user)
    values (sp_profile_name, sp_description, sp_state, now(), sp_user, now(), sp_user);
    
    
    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
                
        -- now we can write a log
        call sp_insert_log_entry('', '15', sp_profile_name, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        call sp_insert_log_entry('', '16', sp_profile_name, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_profile_name, '#', code, '#', msg));
        call sp_insert_log_entry('', '17', v_message, 'failed', sp_user);
    end if;    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_device_profiles_to_device_groups` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_insert_device_profiles_to_device_groups`(OUT sp_result int, IN sp_idprofile int, IN sp_idgroup int, IN sp_order int, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 09.12.2015
    --  Last change : 09.12.2015
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, after the device
    --                profile assigned to device group
    --
    --  09.12.2015  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    
   
    -- declare variable
    declare v_message text;
    declare v_profile_name varchar(45);
    declare v_device_group varchar(45);
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;

    insert into `device_profiles_to_device_groups` (`device_profiles_iddevice_profiles`, `device_groups_iddevice_groups`, `order`, `insert_timestamp`, `insert_user`, `modify_timestamp`, `modify_user`)
    values (sp_idprofile, sp_idgroup, sp_order, now(), sp_user, now(), sp_user);
    
    -- get data for logging
    set v_profile_name = (select profile_name from device_profiles where iddevice_profiles = sp_idprofile);
    set v_device_group = (select device_group_name from device_groups where iddevice_groups = sp_idgroup);
    
    
    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- prepare message for logging
        set v_message = (SELECT CONCAT(v_profile_name, '#', v_device_group));
        
        -- now we can write a log
        call sp_insert_log_entry('', '18', v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        set v_message = (SELECT CONCAT(v_profile_name, '#', v_device_group));
        call sp_insert_log_entry('', '19', v_message, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(v_profile_name, '#', v_device_group,'#', code, '#', msg));
        call sp_insert_log_entry('', '20', v_message, 'failed', sp_user);
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_device_profile_settings` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_insert_device_profile_settings`(OUT sp_result int, IN sp_iddevice_profile int, IN sp_categorie varchar(45), IN sp_setting_name varchar(45), IN sp_value varchar(45), IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 11.01.2016
    --  Last change : 11.01.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, after profile setting is 
    --                inserted or updated
    --
    --  11.01.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------

    -- declare variable
    declare v_message text;
    declare vProfile varchar(45);
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;

	-- we insert or update the setting for a given profile
	insert into device_profile_settings (`device_profiles_iddevice_profiles`, `setting_categorie_name`, `setting_name`, `value`, `insert_timestamp`, `insert_user`, `modify_timestamp`, `modify_user`)
	values (sp_iddevice_profile, sp_categorie, sp_setting_name, sp_value, now(), sp_user, now(), sp_user)
	ON DUPLICATE KEY UPDATE
		`value`     = VALUES(`value`),
		`modify_timestamp` = VALUES(`modify_timestamp`),
		`modify_user` = VALUES(`modify_user`);

	-- prepare for logging
	set vProfile = (SELECT profile_name from device_profiles where iddevice_profiles = sp_iddevice_profile);
        
    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- prepare values
        set v_message = (SELECT CONCAT(sp_setting_name, '#', vProfile, '#', sp_categorie, '#', sp_value));
        
        -- now we can write a log
        call sp_insert_log_entry('', '40', v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        set v_message = (SELECT CONCAT(sp_setting_name, '#', vProfile, '#', sp_categorie, '#', sp_value));
        call sp_insert_log_entry('', '41', v_message, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_setting_name, '#', vProfile, '#', sp_categorie, '#', sp_value, '#', code, '#', msg));
        call sp_insert_log_entry('', '42', v_message, 'failed', sp_user);
    end if;  
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_device_to_device_group` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_insert_device_to_device_group`(OUT sp_result int, IN sp_iddevice int, IN sp_iddevice_group int, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 08.12.2015
    --  Last change : 08.12.2015
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the device created
    --
    --  08.12.2015  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    
   
    -- declare variable
    declare v_message text;
    declare v_device_name varchar(45);
    declare v_device_group varchar(45);
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;

    insert into devices_to_device_groups (device_iddevice, device_groups_iddevice_groups, insert_timestamp, insert_user, modify_timestamp, modify_user)
    values (sp_iddevice, sp_iddevice_group, now(), sp_user, now(), sp_user);
    
    set v_device_name = (select device_name from device where iddevice = sp_iddevice);
    set v_device_group = (select device_group_name from device_groups where iddevice_groups = sp_iddevice_group);
    
    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- prepare message for logging
        set v_message = (SELECT CONCAT(v_device_name, '#', v_device_group));
        
        -- now we can write a log
        call sp_insert_log_entry(v_device_name, '21', v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        set v_message = (SELECT CONCAT(v_device_name, '#', v_device_group));
        call sp_insert_log_entry(v_device_name, '22', v_message, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(v_device_name, '#', v_device_group , '#', code, '#', msg));
        call sp_insert_log_entry(v_device_name, '23', v_message, 'failed', sp_user);
    end if;    

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_device_to_register` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_insert_device_to_register`(OUT sp_result int, IN sp_mac varchar(45), IN sp_hostname varchar(45), IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2016
    -- ------------------------------------------------------------
    --  Created     : 06.10.2016
    --  Last change : 06.10.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We add a job to register an unknown device
    --                and collect some logs.
    --
    --  06.10.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------

    -- declare variable
    declare v_message text;
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;
        
	INSERT INTO device_registering_jobs (`timestamp`, `mac`, `hostname`, `insert_timestamp`, `insert_user`, `modify_timestamp`, `modify_user`)
    VALUES (now(), sp_mac, sp_hostname, now(), sp_user, now(), sp_user);
    
        -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
		set sp_result = 1;
        
        -- prepare message for logging
        set v_message = (SELECT CONCAT(sp_mac, '#', sp_hostname));
        
        -- now we can write a log
        call sp_insert_log_entry('', 80, v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        call sp_insert_log_entry('', 81, sp_mac, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_mac, '#', `code`, '#', msg));
        call sp_insert_log_entry('', 82, v_message, 'failed', sp_user);
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_log_entry` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_insert_log_entry`(IN sp_device_name varchar(45), IN sp_idmessage text, IN sp_values varchar(200), IN sp_status_code varchar(15), IN sp_user varchar(45))
BEGIN
    insert into logs (`device_name`, `messages_idmessages`, `values`, `status_code`, `insert_timestamp`, `insert_user`, `modify_timestamp`, `modify_user`)
    values (sp_device_name, sp_idmessage, sp_values, sp_status_code, now(), sp_user, now(), sp_user);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_scheduled_tasks` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_insert_scheduled_tasks`(OUT sp_result int, IN sp_task_name varchar(45), IN sp_description varchar(200), IN sp_state varchar(45), IN sp_start_date datetime, IN sp_end_date datetime, IN sp_minute varchar(45), IN sp_hour varchar(45), IN sp_day_of_month varchar(45), IN sp_month varchar(45), IN sp_weekday varchar(45), IN sp_idcommand int, IN sp_device_groups varchar(200), IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2016
    -- ------------------------------------------------------------
    --  Created     : 14.10.2016
    --  Last change : 14.10.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert new scheduled tasks and insert also
    --                some logs.
    --
    --  14.10.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------

    -- declare variable
    declare v_message text;
	DECLARE stop int DEFAULT 0;
	DECLARE Vposition int;
	DECLARE Vpart_string varchar(200);
	DECLARE Vnew_text text;
    declare v_lid int;
    declare vc_command_name varchar(45);
    declare vdevice_name varchar(45);
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;
        
	INSERT INTO scheduled_tasks (`task_name`, `description`, `state`, `start_date`, `end_date`, `minute`, `hour`, `day_of_month`, `month`, `weekday`, `commands_idcommands`, `insert_timestamp`, `insert_user`, `modify_timestamp`, `modify_user`)
    VALUES (sp_task_name, sp_description, sp_state, sp_start_date, sp_end_date, sp_minute, sp_hour, sp_day_of_month, sp_month, sp_weekday, sp_idcommand, now(), sp_user, now(), sp_user);
    
    set v_lid = LAST_INSERT_ID();
    
    
	-- find the first '#'
	WHILE stop = 0
	 DO
	  SET Vposition = (SELECT LOCATE('#', sp_device_groups));

      -- check if only one value is at this list or it's the last one.
	  IF Vposition = 0 
	  THEN
	   BEGIN
		SET stop = 1;
        insert into scheduled_tasks_to_device_groups (`scheduled_tasks_idscheduled_tasks`, `device_groups_iddevice_groups`, `insert_timestamp`, `insert_user`, `modify_timestamp`, `modify_user`)
        VALUES( v_lid, sp_device_groups, now(), sp_user, now(), sp_user);
	   END;
	  ELSE
       BEGIN
	    -- extract string
	    SET Vpart_string = (SELECT substring(sp_device_groups, 1, (Vposition - 1)));

	    -- set value in log text
	    insert into scheduled_tasks_to_device_groups (`scheduled_tasks_idscheduled_tasks`, `device_groups_iddevice_groups`, `insert_timestamp`, `insert_user`, `modify_timestamp`, `modify_user`)
        VALUES( v_lid, Vpart_string, now(), sp_user, now(), sp_user);
        
	    -- remove part string vom origin
	    SET Vpart_string = (SELECT CONCAT(Vpart_string, '#'));
	    SET sp_device_groups = (SELECT REPLACE(sp_device_groups, Vpart_string, ''));
       END;
	  END IF;
	 END WHILE;

	-- get information for logging
    set vc_command_name = (SELECT `commmand_name` from commands where `idcommands` = sp_idcommand);

    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
		set sp_result = 1;
        
        -- prepare message for logging
        set v_message = (SELECT CONCAT(sp_task_name, '#', vc_command_name));
        
        -- now we can write a log
        call sp_insert_log_entry('', 89, v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        set v_message = (SELECT CONCAT(sp_task_name, '#', vc_command_name));
        call sp_insert_log_entry('', 90, v_message, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_task_name, '#', vc_command_name, '#', `code`, '#', msg));
        call sp_insert_log_entry('', 91, v_message, 'failed', sp_user);
    end if;    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_insert_user`(OUT sp_result int, IN sp_usergroup_id int, IN sp_username varchar(45), IN sp_password varchar(90), IN sp_email varchar(45), IN sp_state int, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 04.12.2015
    --  Last change : 21.02.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the user created
    --
    --  04.12.2015  : Created
    --  21.02.2016	: Also insert user to usergroup
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    
   
    -- declare variable
    declare v_message text;
    declare lid int; -- last inserted id from table 'users'
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;


    insert into users (username, password, email, state, insert_timestamp, insert_user, modify_timestamp, modify_user)
    values (sp_username, sp_password, sp_email, sp_state, now(), sp_user, now(), sp_user);
    
	-- get latest inserted id from table 'users'
    set lid = last_insert_id();
    
    -- insert user and usergroup
    insert into users_to_usergroups (users_idusers, usergroups_idusergroups, insert_timestamp, insert_user, modify_timestamp, modify_user)
    values (lid, sp_usergroup_id, now(), sp_user, now(), sp_user);
    

    -- check whether the insert was successful
    IF code = '00000' THEN
     BEGIN
        -- insert was successfull
        set sp_result = 1;
        
        -- now we can write a log
        call sp_insert_log_entry('', '1', sp_username, 'success', sp_user);
	 END;
        
    else
     BEGIN
        -- insert failed
        set sp_result = 0;

        call sp_insert_log_entry('', '2', sp_username, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_username, '#', code, '#', msg));
        call sp_insert_log_entry('', '3', v_message, 'failed', sp_user);
	 END;
    end if;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_usergroup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_insert_usergroup`(OUT sp_result int, IN sp_groupname varchar(45), IN sp_description text, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 21.02.2016
    --  Last change : 21.02.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the usergroup created
    --
    --  21.02.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
        
   
    -- declare variable
    declare v_message text;
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;
      
    -- insert usergroup
    insert into usergroups (group_name, description, insert_timestamp, insert_user, modify_timestamp, modify_user)
    values (sp_groupname, sp_description, now(), sp_user, now(), sp_user);

    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- now we can write a log
        call sp_insert_log_entry('', '55', sp_groupname, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        call sp_insert_log_entry('', '56', sp_groupname, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_groupname, '#', code, '#', msg));
        call sp_insert_log_entry('', '57', v_message, 'failed', sp_user);
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_show_logs` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_show_logs`(IN sp_device_name varchar(45), IN sp_locals varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 01.01.2016
    --  Last change : 01.01.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We prepare log for webfrontend
    --
    --  01.01.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
	 
	-- declare variable
	DECLARE Vlocals varchar(45);
	DECLARE Vdevice_name varchar(45);
	DECLARE Vstatus_code varchar(15);
	DECLARE Vmodify_user varchar(45);
	DECLARE Vmodify_timestamp datetime;
	DECLARE Vlevel varchar(5);
	DECLARE Vtext_translation text;
	DECLARE Vidlocales varchar(5);
	DECLARE Vvalues varchar(200);
	DECLARE finished INTEGER DEFAULT 0;
	DECLARE Vposition int;
	DECLARE Vpart_string varchar(200);
	DECLARE Vnew_text text;
	DECLARE stop int DEFAULT 0;

	-- prepare locals
	SET Vlocals = (SELECT CONCAT(sp_locals, '%'));
    
	-- create temp table as first
	CREATE TEMPORARY TABLE `tmp_logs` (
	`device_name` varchar(45) NULL,
	`status_code` varchar(15) NULL,
	`modify_user` varchar(45) NULL,
	`modify_timestamp` datetime NULL,
	`level` varchar(5) NULL,
	`text_translation` text NULL,
	`idlocales` varchar(5) NULL,
	`values` varchar(200) NULL
	);

	-- declare cursor
    BEGIN     
	 DECLARE cursor_log CURSOR FOR
	 SELECT `device_name`, `status_code`, `modify_user`, `modify_timestamp`, `level`, `text_translation`, `idlocales`, `values` FROM v_logs 
	 WHERE 1=1
     AND `idlocales` like Vlocals
	 AND CASE WHEN sp_device_name <> '' THEN `device_name` = sp_device_name ELSE ((`device_name` = '' or `device_name` = sp_device_name)) END;
     
	 -- declare NOT FOUND handler
	 DECLARE CONTINUE HANDLER FOR NOT FOUND SET stop = 1;

	 -- open cursor
	 OPEN cursor_log;

	 get_logs: LOOP
	 FETCH cursor_log INTO Vdevice_name, Vstatus_code, Vmodify_user, Vmodify_timestamp, Vlevel, Vtext_translation, Vidlocales, Vvalues;


	 IF stop = 1 
	 THEN 
	  BEGIN
	   LEAVE get_logs;
	  END;
	 END IF;

	 -- find the first '#'
	 WHILE stop = 0
	 DO
	  SET Vposition = (SELECT LOCATE('#', Vvalues));

      -- check if only one value is at this list.
	  IF Vposition = 0 
	  THEN
	   BEGIN
        SET Vnew_text = (SELECT CONCAT(REPLACE(LEFT(Vtext_translation, INSTR(Vtext_translation, '#')), '#', Vvalues), SUBSTRING(Vtext_translation, INSTR(Vtext_translation, '#') + 1)));
       END;
	  ELSE
       BEGIN
	    -- extract string
	    SET Vpart_string = (SELECT substring(Vvalues, 1, (Vposition - 1)));

	    -- set value in log text
	    SET Vnew_text = (SELECT CONCAT(REPLACE(LEFT(Vtext_translation, INSTR(Vtext_translation, '#')), '#', Vpart_string), SUBSTRING(Vtext_translation, INSTR(Vtext_translation, '#') + 1)));
 
	    -- remove part string vom origin
	    SET Vpart_string = (SELECT CONCAT(Vpart_string, '#'));
	    SET Vvalues = (SELECT REPLACE(Vvalues, Vpart_string, ''));
       END;
	  END IF;
      
	  -- if we find no other '#', then the locate function returns '0'
	  IF Vposition = 0 
	  THEN
	   BEGIN
		SET stop = 1;
  
		-- insert that log entry in tmp table
		INSERT INTO tmp_logs (`device_name`, `status_code`, `modify_user`, `modify_timestamp`, `level`, `text_translation`, `idlocales`, `values`)
		VALUES (Vdevice_name, Vstatus_code, Vmodify_user, Vmodify_timestamp, Vlevel, Vnew_text, Vidlocales, Vvalues);
	   END;
	  END IF;
	 END WHILE;

	 END LOOP get_logs;
 
	 CLOSE cursor_log;
   END;

 SELECT * FROM tmp_logs;
 DROP TABLE tmp_logs;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_command_jobs` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_update_command_jobs`(OUT sp_result int, IN sp_user varchar(45), IN sp_idcommand_jobs int, IN sp_status varchar(7), IN sp_message text)
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 04.12.2015
    --  Last change : 04.12.2015
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We update the command jobs and insert some
    --                logs.
    --
    --  04.12.2015  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------

    -- declare some variables
    declare vdevice_name varchar(45);
    declare vc_description text;
    declare v_message text;
    declare vc_command_name varchar(45);
	declare v_interval int;
    declare v_commandid int;
    declare v_deviceid int;
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;
    
    -- getting data
    set vdevice_name = (select device_name from v_command_jobs where idcommand_jobs = sp_idcommand_jobs limit 1);
    set vc_command_name = (select command_name from v_command_jobs where idcommand_jobs = sp_idcommand_jobs limit 1);

    -- We have to check which status the job has
    IF sp_status = 'success' THEN
        -- update the job
        update command_jobs
        set state = 'success', modify_timestamp = now(), modify_user = sp_user
        where idcommand_jobs = sp_idcommand_jobs;
              
        -- check whether the update was successful
        IF code = '00000' THEN
            -- insert was successfull
            set sp_result = 1;
        
			-- create a new job if interval is not 0
			set v_interval = (SELECT `interval` from `v_command_jobs` where `idcommand_jobs` = sp_idcommand_jobs);
        
			IF v_interval > 0 THEN
				set v_deviceid = (SELECT `iddevice` from `v_command_jobs` where `idcommand_jobs` = sp_idcommand_jobs);
				set v_commandid = (SELECT `idcommands` from `v_command_jobs` where `idcommand_jobs` = sp_idcommand_jobs);
				call sp_insert_command_jobs(@out, v_commandid, v_deviceid, v_interval, '', 'agent');
			END IF;
        
            -- insert a log entry
            set v_message = (SELECT CONCAT(vc_command_name, '#', 'success'));
            call sp_insert_log_entry('', 27, v_message, 'success', sp_user);
        ELSE
            -- insert failed
            set sp_result = 0;
        
            -- now we can write a log
            -- info for user
            set v_message = (SELECT CONCAT(sp_idcommand_jobs, '#', vc_command_name));
            call sp_insert_log_entry('', 28, v_message, 'failed', sp_user);
        
            -- debugging
            set v_message = (SELECT CONCAT(vc_command_name, '#', code, '#', msg));
            call sp_insert_log_entry('', 29, v_message, 'failed', sp_user);
        END IF;
        
    ELSEIF sp_status = 'failed' THEN
    
        -- update the job 
        update command_jobs
        set state = 'failed', modify_timestamp = now(), modify_user = sp_user
        where idcommand_jobs = sp_idcommand_jobs;
        
        -- check whether the update was successful
        IF code = '00000' THEN
            -- update was successfull
            set sp_result = 1;
        
        
            -- insert a log entry
            set v_message = (SELECT CONCAT(vc_command_name, '#', 'failed'));
            call sp_insert_log_entry('', 27, vc_command_name, 'failed', sp_user);
            
            -- job failed
            set v_message = (SELECT CONCAT(sp_idcommand_jobs, '#', vc_command_name, '#', vdevice_name));
            call sp_insert_log_entry('', 67, v_message, 'failed', sp_user);
            
            -- set debugging information for failed job.
            set v_message = (SELECT CONCAT(sp_idcommand_jobs, '#', sp_message));
            call sp_insert_log_entry('', 68, v_message, 'failed', sp_user);
        ELSE
            -- update failed
            set sp_result = 0;
        
            -- now we can write a log
            -- info for user
            call sp_insert_log_entry('', 69, sp_idcommand_jobs, 'failed', sp_user);
        
            -- debugging
            set v_message = (SELECT CONCAT(sp_idcommand_jobs, '#', code, '#', msg));
            call sp_insert_log_entry('', 70, v_message, 'failed', sp_user);
        END IF;
            
    ELSE
        -- status = pending
        -- update the job 
        update command_jobs
        set state = 'pending', modify_timestamp = now(), modify_user = sp_user
        where idcommand_jobs = sp_idcommand_jobs;
        
        -- check whether the update was successful
        IF code = '00000' THEN
            -- update was successfull
            set sp_result = 1;
        
            -- prepare message for logging
            set v_message = (SELECT CONCAT(vc_command_name, '#', 'pending'));
        
            -- insert a log entry
            call sp_insert_log_entry('', 27, v_message, 'success', sp_user);
            
            -- job pending
            set v_message = (SELECT CONCAT(vc_command_name, '#', vdevice_name));
            call sp_insert_log_entry('', 71, v_message, 'pending', sp_user);
        ELSE
            -- update failed
            set sp_result = 0;
        
            -- now we can write a log
            -- info for user
			call sp_insert_log_entry('', 69, sp_idcommand_jobs, 'failed', sp_user);
        
            -- debugging
            set v_message = (SELECT CONCAT(sp_idcommand_jobs, '#', code, '#', msg));
            call sp_insert_log_entry('', 70, v_message, 'failed', sp_user);
        END IF;        
        
    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_device` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_update_device`(OUT sp_result int, IN sp_iddevice int, IN sp_device_name varchar(45), IN sp_mac_address varchar(45), IN sp_ip_address varchar(45), IN sp_serialnumber varchar(45), IN sp_note text, IN sp_device_type int, IN sp_device_group int, IN sp_photo varchar(255), IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 07.12.2015
    --  Last change : 07.12.2015
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the device updated
    --
    --  07.12.2015  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    
   
    -- declare variable
    declare v_message text;
    declare v_device_group int;
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;
      
    -- we didn't update serialnumber 
    update device
    set device_name = sp_device_name, mac_address = sp_mac_address, ip_address = sp_ip_address, note = sp_note, device_photo = sp_photo, modify_timestamp = now(), modify_user = sp_user, device_types_iddevice_types = sp_device_type
    where iddevice = sp_iddevice;
    
    -- we check if we have to change the group of this device
    set v_device_group = (select device_groups_iddevice_groups from device_to_device_groups where device_iddevice = sp_iddevice limit 1);
    
    IF v_device_group <> sp_device_group THEN
        -- it's not the same. we have to update it
        update device_to_device_groups 
        set device_groups_iddevice_groups = sp_device_group, modify_timestamp = now(), modify_user = sp_user 
        where device_iddevice = sp_iddevice;
    END IF;


    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- now we can write a log
        call sp_insert_log_entry('', '30', sp_device_name, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        call sp_insert_log_entry('', '31', sp_device_name, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_device_name, '#', code, '#', msg));
        call sp_insert_log_entry('', '32', v_message, 'failed', sp_user);
    end if;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_device_group` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_update_device_group`(OUT sp_result INT, IN sp_group_id int, IN sp_group_name varchar(45), IN sp_description text, IN sp_state int, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 30.01.2016
    --  Last change : 30.01.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the device 
    --                group is updated
    --
    --  30.01.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    
   
    -- declare variable
    declare v_message text;
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;
      
    update device_groups 
    set device_group_name = sp_group_name, description = sp_description, state = sp_state, modify_timestamp = now(), modify_user = sp_user
    where iddevice_groups = sp_group_id;
      
    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- now we can write a log
        call sp_insert_log_entry('', '46', sp_group_name, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        call sp_insert_log_entry('', '47', sp_group_name, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_group_name, '#', code, '#', msg));
        call sp_insert_log_entry('', '48', v_message, 'failed', sp_user);
    end if;    

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_device_performance_data` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_update_device_performance_data`(OUT sp_result int, IN sp_iddevice int, IN sp_name varchar(45), IN sp_value varchar(45), IN sp_jobid varchar(5), IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 12.08.2016
    --  Last change : 12.08.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the device updated
    --
    --  12.08.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------

    -- declare variable
    declare v_message text;
    declare v_device_name varchar(45);
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;
      
    -- we update state of the device
    update device_performance_data
    set value = sp_value, modify_timestamp = now(), modify_user = sp_user
    where name = sp_name and device_iddevice = sp_iddevice;
    
    -- we update the last_check value
    update device_performance_data
    set value_date = now(), modify_timestamp = now(), modify_user = sp_user
    where name = 'last_check' and device_iddevice = sp_iddevice;
    
    
    set v_device_name = (SELECT device_name from device where iddevice = sp_iddevice);
    

    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- set job done, only for jobs where the sp called once
        IF sp_name = "state" THEN
			call sp_update_command_jobs(@out, 'agent', sp_jobid, 'success', '');
        END IF;
        
        -- now we can write a log
        set v_message = (SELECT CONCAT(sp_name, '#', v_device_name, '#', sp_value));
        call sp_insert_log_entry('', 61, v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        call sp_insert_log_entry('', 62, v_device_name, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(v_device_name, '#', code, '#', msg));
        call sp_insert_log_entry('', 63, v_message, 'failed', sp_user);
    end if;    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_device_profiles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_update_device_profiles`(OUT sp_result int, IN sp_idprofile int, IN sp_profile_name varchar(45), IN sp_description text, IN sp_state int, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 09.12.2015
    --  Last change : 09.12.2015
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the device 
    --                profile is updated
    --
    --  09.12.2015  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    
   
    -- declare variable
    declare v_message text;
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;
      
    update device_profiles 
    set profile_name = sp_profile_name, description = sp_description, state = sp_state, modify_timestamp = now(), modify_user = sp_user
    where iddevice_profiles = sp_idprofile;
      
    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- now we can write a log
        call sp_insert_log_entry('', '33', sp_profile_name, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        call sp_insert_log_entry('', '34', sp_profile_name, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_profile_name, '#', code, '#', msg));
        call sp_insert_log_entry('', '35', v_message, 'failed', sp_user);
    end if;       
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_device_registering_job` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_update_device_registering_job`(OUT sp_result int, IN sp_id int, IN sp_state varchar(45), IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2016
    -- ------------------------------------------------------------
    --  Created     : 11.10.2016
    --  Last change : 11.10.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We update the device registering jobs and insert some
    --                logs.
    --
    --  11.10.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------

    -- declare variable
    declare v_message text;
    declare v_mac varchar(45);
    declare v_devicename varchar(45);
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;    
        
	update device_registering_jobs 
    set `state` = sp_state, `modify_timestamp` = now(), `modify_user` = sp_user 
    where `iddevice_registering_jobs` = sp_id;
    
    set v_mac = (SELECT `mac` from `device_registering_jobs` where `iddevice_registering_jobs` = sp_id);
    set v_devicename = (SELECT `hostname ` from `device_registering_jobs` where `iddevice_registering_jobs` = sp_id);
    
    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
		set sp_result = 1;
        
        -- prepare message for logging
        set v_message = (SELECT CONCAT(v_mac, '#', sp_state));
        
        -- now we can write a log
        call sp_insert_log_entry('', 86, v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        set v_message = (SELECT CONCAT(v_mac, '#', v_devicename));
        call sp_insert_log_entry('', 84, v_message, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(v_mac, '#', v_devicename, '#', `code`, '#', msg));
        call sp_insert_log_entry('', 88, v_message, 'failed', sp_user);
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_device_state` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_update_device_state`(OUT sp_result int, IN sp_deviceid int, IN sp_state varchar(45), IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2016
    -- ------------------------------------------------------------
    --  Created     : 11.10.2016
    --  Last change : 11.10.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the device updated
    --
    --  11.10.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------

    -- declare variable
    declare v_message text;
    declare v_device_name varchar(45);
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;
        
	-- get device name
    set v_device_name = (SELECT `device_name` FROM `device` WHERE `iddevice` = sp_deviceid);
        
	-- update device state
    update `device` set `state` = sp_state, `modify_timestamp` = now(), `modify_user` = sp_user
    where `iddevice` = sp_deviceid;

    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- now we can write a log
        set v_message = (SELECT CONCAT(v_device_name, '#', sp_state));
        call sp_insert_log_entry('', 61, v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        call sp_insert_log_entry('', 62, v_device_name, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(v_device_name, '#', code, '#', msg));
        call sp_insert_log_entry('', 63, v_message, 'failed', sp_user);
    end if;       

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_device_uptime` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_update_device_uptime`(OUT sp_result int, IN sp_iddevice int, IN sp_name varchar(45), IN sp_value varchar(45), IN sp_jobid varchar(5), IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2016
    -- ------------------------------------------------------------
    --  Created     : 28.09.2016
    --  Last change : 28.09.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the device updated
    --
    --  28.09.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------

    -- declare variable
    declare v_message text;
    declare v_device_name varchar(45);
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;
      
    -- we update state of the device
    update device_performance_data
    set value = sp_value, modify_timestamp = now(), modify_user = sp_user
    where name = sp_name and device_iddevice = sp_iddevice;
    
    -- we update the last_check value
    update device_performance_data
    set value_date = now(), modify_timestamp = now(), modify_user = sp_user
    where name = 'last_check' and device_iddevice = sp_iddevice;
    
    
    set v_device_name = (SELECT device_name from device where iddevice = sp_iddevice);
    

    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- set job done
        call sp_update_command_jobs(@out, 'agent', sp_jobid, 'success', '');
        
        -- now we can write a log
        set v_message = (SELECT CONCAT(v_device_name, '#', sp_value));
        call sp_insert_log_entry('', 74, v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        call sp_insert_log_entry('', 75, v_device_name, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(v_device_name, '#', code, '#', msg));
        call sp_insert_log_entry('', 76, v_message, 'failed', sp_user);
    end if;    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_user_email` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_update_user_email`(OUT sp_result int, IN sp_iduser int, IN sp_email varchar(90), IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 21.02.2016
    --  Last change : 21.02.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the user's email
	--  			  updated
    --
    --  21.02.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    
   
    -- declare variable
    declare v_message text;
    declare v_username varchar(45);
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;


    update users 
    set email = sp_email, modify_timestamp = now(), modify_user = sp_user
    where idusers = sp_iduser;
    
    set v_username = (SELECT username FROM users WHERE idusers = sp_iduser);

    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- now we can write a log
        call sp_insert_log_entry('', '52', v_username, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;

        call sp_insert_log_entry('', '53', v_username, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(v_username, '#', code, '#', msg));
        call sp_insert_log_entry('', '54', v_message, 'failed', sp_user);
    end if;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_user_password` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_update_user_password`(OUT sp_result int, IN sp_iduser int, IN sp_password varchar(90), IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 24.12.2015
    --  Last change : 21.02.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the user passsword
	--  			  updated
    --
    --  24.12.2015  : Created
    --  21.02.2016	: Change to only update users password.
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    
   
    -- declare variable
    declare v_message text;
	declare v_username varchar(45);
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;


    update users 
    set password = sp_password, modify_timestamp = now(), modify_user = sp_user
    where idusers = sp_iduser;

	set v_username = (SELECT username FROM users WHERE idusers = sp_iduser);

    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- now we can write a log
        call sp_insert_log_entry('', '5', v_username, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;

        call sp_insert_log_entry('', '6', v_username, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(v_username, '#', code, '#', msg));
        call sp_insert_log_entry('', '7', v_message, 'failed', sp_user);
    end if;


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_user_usergroup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_update_user_usergroup`(OUT sp_result int, IN sp_iduser int, IN sp_usergroup int, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 21.02.2016
    --  Last change : 21.02.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer update user to
    --  			  usergroup
    --
    --  21.02.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
     -- declare variable
    declare v_message text;
    declare v_usergroup varchar(45);
    declare v_username varchar(45);
    declare v_before_usergroup varchar(45);
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;


	-- get usergroup before update
    set v_before_usergroup = (SELECT group_name FROM v_users WHERE idusers = sp_iduser);
      
    -- update users_to_usergroups
    update users_to_usergroups set usergroups_idusergroups = sp_usergroup, modify_timestamp = now(), modify_user = sp_user where users_idusers = sp_iduser;

	-- get new usergroup
	set v_usergroup = (SELECT group_name FROM usergroups WHERE idusergroups = sp_usergroup);
    
    -- get username
    set v_username = (SELECT username FROM users WHERE idusers = sp_iduser);
    

    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- now we can write a log
        set v_message = (SELECT CONCAT(v_username, '#', v_before_usergroup, '#', v_usergroup)); 
        call sp_insert_log_entry('', '58', v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        
        call sp_insert_log_entry('', '59', v_usergroup, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(v_usergroup, '#', code, '#', msg));
        call sp_insert_log_entry('', '60', v_message, 'failed', sp_user);
    end if;   
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `v_checked_devices`
--

/*!50001 DROP VIEW IF EXISTS `v_checked_devices`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_checked_devices` AS select `d`.`device_name` AS `device_name`,`d`.`iddevice` AS `iddevice`,`d2dg`.`device_groups_iddevice_groups` AS `device_groups_iddevice_groups` from (`device` `d` left join `devices_to_device_groups` `d2dg` on((`d2dg`.`device_iddevice` = `d`.`iddevice`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_command_jobs`
--

/*!50001 DROP VIEW IF EXISTS `v_command_jobs`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_command_jobs` AS select `cj`.`idcommand_jobs` AS `idcommand_jobs`,`cj`.`timestamp` AS `timestamp`,`cj`.`state` AS `state`,`c`.`idcommands` AS `idcommands`,`c`.`command_name` AS `command_name`,`c`.`description` AS `description`,`c`.`command` AS `command`,`c`.`interval` AS `interval`,`d`.`iddevice` AS `iddevice`,`d`.`device_name` AS `device_name`,`d`.`mac_address` AS `mac_address` from ((`command_jobs` `cj` join `commands` `c` on((`cj`.`commands_idcommands` = `c`.`idcommands`))) join `device` `d` on((`cj`.`device_iddevice` = `d`.`iddevice`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_device_groups`
--

/*!50001 DROP VIEW IF EXISTS `v_device_groups`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_device_groups` AS select `device_groups`.`iddevice_groups` AS `iddevice_groups`,`device_groups`.`device_group_name` AS `device_group_name`,`device_groups`.`description` AS `description`,`device_groups`.`state` AS `state`,`device_groups`.`insert_timestamp` AS `insert_timestamp`,`device_groups`.`insert_user` AS `insert_user`,`device_groups`.`modify_timestamp` AS `modify_timestamp`,`device_groups`.`modify_user` AS `modify_user` from `device_groups` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_device_performance_data`
--

/*!50001 DROP VIEW IF EXISTS `v_device_performance_data`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_device_performance_data` AS select `device_performance_data`.`iddevice_performance_data` AS `iddevice_performance_data`,`device_performance_data`.`name` AS `name`,`device_performance_data`.`value` AS `value`,`device_performance_data`.`value_date` AS `value_date`,`device_performance_data`.`insert_timestamp` AS `insert_timestamp`,`device_performance_data`.`insert_user` AS `insert_user`,`device_performance_data`.`modify_timestamp` AS `modify_timestamp`,`device_performance_data`.`modify_user` AS `modify_user`,`device_performance_data`.`device_iddevice` AS `device_iddevice` from `device_performance_data` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_device_profile_settings`
--

/*!50001 DROP VIEW IF EXISTS `v_device_profile_settings`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_device_profile_settings` AS select `dps`.`iddevice_profile_settings` AS `iddevice_profile_settings`,`dps`.`device_profiles_iddevice_profiles` AS `device_profiles_iddevice_profiles`,`dps`.`setting_categorie_name` AS `setting_categorie_name`,`dps`.`setting_name` AS `setting_name`,`dps`.`value` AS `value`,`dps`.`modify_timestamp` AS `modify_timestamp` from (`device_profile_settings` `dps` join `device_profiles` `dp` on((`dps`.`device_profiles_iddevice_profiles` = `dp`.`iddevice_profiles`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_device_profiles`
--

/*!50001 DROP VIEW IF EXISTS `v_device_profiles`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_device_profiles` AS select `device_profiles`.`iddevice_profiles` AS `iddevice_profiles`,`device_profiles`.`profile_name` AS `profile_name`,`device_profiles`.`description` AS `description`,`device_profiles`.`state` AS `state`,`device_profiles`.`insert_timestamp` AS `insert_timestamp`,`device_profiles`.`insert_user` AS `insert_user`,`device_profiles`.`modify_timestamp` AS `modify_timestamp`,`device_profiles`.`modify_user` AS `modify_user` from `device_profiles` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_device_registering_jobs`
--

/*!50001 DROP VIEW IF EXISTS `v_device_registering_jobs`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_device_registering_jobs` AS select `device_registering_jobs`.`iddevice_registering_jobs` AS `iddevice_registering_jobs`,`device_registering_jobs`.`timestamp` AS `timestamp`,`device_registering_jobs`.`state` AS `state`,`device_registering_jobs`.`mac` AS `mac`,`device_registering_jobs`.`hostname` AS `hostname`,`device_registering_jobs`.`group` AS `group`,`device_registering_jobs`.`device_type` AS `device_type`,`device_registering_jobs`.`insert_timestamp` AS `insert_timestamp`,`device_registering_jobs`.`insert_user` AS `insert_user`,`device_registering_jobs`.`modify_timestamp` AS `modify_timestamp`,`device_registering_jobs`.`modify_user` AS `modify_user` from `device_registering_jobs` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_device_settings`
--

/*!50001 DROP VIEW IF EXISTS `v_device_settings`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_device_settings` AS select `ds`.`categorie_name` AS `categorie_name`,`ds`.`setting_name` AS `setting_name`,`t`.`text_translation` AS `text_translation`,`lc`.`idlocales` AS `idlocales` from (((`device_settings` `ds` join `messages` `m` on((`ds`.`messages_idmessages` = `m`.`idmessages`))) join `translations` `t` on((`m`.`idmessages` = `t`.`messages_idmessages`))) join `locales` `lc` on((`t`.`locales_idlocales` = `lc`.`idlocales`))) where ((1 = 1) and (`m`.`level` = 'WEB')) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_device_summary_device_profiles`
--

/*!50001 DROP VIEW IF EXISTS `v_device_summary_device_profiles`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_device_summary_device_profiles` AS select `d`.`device_name` AS `device_name`,`dp`.`profile_name` AS `profile_name`,`dp2dg`.`modify_timestamp` AS `modify_timestamp` from (((`device` `d` join `devices_to_device_groups` `d2dg` on((`d`.`iddevice` = `d2dg`.`device_iddevice`))) join `device_profiles_to_device_groups` `dp2dg` on((`d2dg`.`device_groups_iddevice_groups` = `dp2dg`.`device_groups_iddevice_groups`))) join `device_profiles` `dp` on((`dp2dg`.`device_profiles_iddevice_profiles` = `dp`.`iddevice_profiles`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_device_to_device_group`
--

/*!50001 DROP VIEW IF EXISTS `v_device_to_device_group`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_device_to_device_group` AS select `d`.`iddevice` AS `iddevice`,`d`.`device_name` AS `device_name`,`d`.`mac_address` AS `mac_address`,`d`.`serialnumber` AS `serialnumber`,`d`.`note` AS `note`,`d`.`device_photo` AS `device_photo`,`d`.`state` AS `d_state`,`dg`.`iddevice_groups` AS `iddevice_groups`,`dg`.`device_group_name` AS `device_group_name`,`dg`.`description` AS `description`,`dg`.`state` AS `dg_state`,`d`.`insert_timestamp` AS `insert_timestamp`,`d`.`insert_user` AS `insert_user`,`d`.`modify_timestamp` AS `modify_timestamp`,`d`.`modify_user` AS `modify_user`,`d2dg`.`modify_timestamp` AS `group_date_assigned` from ((`device` `d` join `devices_to_device_groups` `d2dg` on((`d`.`iddevice` = `d2dg`.`device_iddevice`))) join `device_groups` `dg` on((`d2dg`.`device_groups_iddevice_groups` = `dg`.`iddevice_groups`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_devices`
--

/*!50001 DROP VIEW IF EXISTS `v_devices`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_devices` AS select `d`.`iddevice` AS `iddevice`,`d`.`device_name` AS `device_name`,`d`.`state` AS `state`,`dt`.`device_type_name` AS `device_type_name`,`d`.`serialnumber` AS `serialnumber`,`d`.`note` AS `note`,`d`.`mac_address` AS `mac_address`,`d`.`device_photo` AS `photo` from (`device` `d` join `device_types` `dt` on((`d`.`device_types_iddevice_types` = `dt`.`iddevice_types`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_logs`
--

/*!50001 DROP VIEW IF EXISTS `v_logs`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_logs` AS select `l`.`device_name` AS `device_name`,`l`.`status_code` AS `status_code`,`l`.`modify_user` AS `modify_user`,`l`.`modify_timestamp` AS `modify_timestamp`,`m`.`level` AS `level`,`t`.`text_translation` AS `text_translation`,`lc`.`idlocales` AS `idlocales`,`l`.`values` AS `values` from (((`logs` `l` join `messages` `m` on((`l`.`messages_idmessages` = `m`.`idmessages`))) join `translations` `t` on((`m`.`idmessages` = `t`.`messages_idmessages`))) join `locales` `lc` on((`t`.`locales_idlocales` = `lc`.`idlocales`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_profile_to_device_group`
--

/*!50001 DROP VIEW IF EXISTS `v_profile_to_device_group`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_profile_to_device_group` AS select `dp`.`iddevice_profiles` AS `iddevice_profiles`,`dp`.`profile_name` AS `profile_name`,`dp`.`state` AS `dp_state`,`dp2dg`.`insert_timestamp` AS `insert_timestamp`,`dp2dg`.`insert_user` AS `insert_user`,`dp2dg`.`modify_timestamp` AS `modify_timestamp`,`dp2dg`.`modify_user` AS `modify_user`,`dg`.`iddevice_groups` AS `iddevice_groups`,`dg`.`device_group_name` AS `device_group_name`,`dg`.`description` AS `description`,`dg`.`state` AS `state` from ((`device_profiles` `dp` join `device_profiles_to_device_groups` `dp2dg` on((`dp`.`iddevice_profiles` = `dp2dg`.`device_profiles_iddevice_profiles`))) join `device_groups` `dg` on((`dp2dg`.`device_groups_iddevice_groups` = `dg`.`iddevice_groups`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_scheduled_tasks_jobs`
--

/*!50001 DROP VIEW IF EXISTS `v_scheduled_tasks_jobs`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_scheduled_tasks_jobs` AS select `scheduled_tasks`.`idscheduled_tasks` AS `idscheduled_tasks`,`scheduled_tasks`.`task_name` AS `task_name`,`scheduled_tasks`.`description` AS `description`,`scheduled_tasks`.`state` AS `state`,`scheduled_tasks`.`start_date` AS `start_date`,`scheduled_tasks`.`end_date` AS `end_date`,`scheduled_tasks`.`minute` AS `minute`,`scheduled_tasks`.`hour` AS `hour`,`scheduled_tasks`.`day_of_month` AS `day_of_month`,`scheduled_tasks`.`month` AS `month`,`scheduled_tasks`.`weekday` AS `weekday`,`devices_to_device_groups`.`device_iddevice` AS `device_iddevice`,`commands`.`idcommands` AS `idcommands`,`commands`.`command_name` AS `command_name`,`commands`.`command` AS `command` from (((`scheduled_tasks` join `commands` on((`scheduled_tasks`.`commands_idcommands` = `commands`.`idcommands`))) join `scheduled_tasks_to_device_groups` on((`scheduled_tasks`.`idscheduled_tasks` = `scheduled_tasks_to_device_groups`.`scheduled_tasks_idscheduled_tasks`))) join `devices_to_device_groups` on((`scheduled_tasks_to_device_groups`.`device_groups_iddevice_groups` = `devices_to_device_groups`.`device_groups_iddevice_groups`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_user_rights_to_usergroups`
--

/*!50001 DROP VIEW IF EXISTS `v_user_rights_to_usergroups`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_user_rights_to_usergroups` AS select `ur`.`iduser_rights` AS `iduser_rights`,`ur`.`user_right_name` AS `user_right_name`,`ur`.`user_right_group` AS `user_right_group`,`ug`.`idusergroups` AS `idusergroups`,`ug`.`group_name` AS `group_name` from ((`user_rights_to_usergroups` `ur2ug` join `user_rights` `ur` on((`ur2ug`.`user_rights_iduser_rights` = `ur`.`iduser_rights`))) join `usergroups` `ug` on((`ur2ug`.`usergroups_idusergroups` = `ug`.`idusergroups`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_users`
--

/*!50001 DROP VIEW IF EXISTS `v_users`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_users` AS select `u`.`idusers` AS `idusers`,`ug`.`idusergroups` AS `idusergroups`,`u`.`username` AS `username`,`u`.`password` AS `password`,`u`.`email` AS `email`,`u`.`user_photo` AS `user_photo`,`u`.`modify_timestamp` AS `user_timestamp`,`u`.`modify_user` AS `user_modify`,`ug`.`group_name` AS `group_name`,`ug`.`description` AS `description`,`ug`.`modify_timestamp` AS `usergroup_timestamp`,`ug`.`modify_user` AS `usergroup_modify` from ((`users` `u` join `users_to_usergroups` `u2ug` on((`u`.`idusers` = `u2ug`.`users_idusers`))) join `usergroups` `ug` on((`u2ug`.`usergroups_idusergroups` = `ug`.`idusergroups`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-12-05 11:14:57
