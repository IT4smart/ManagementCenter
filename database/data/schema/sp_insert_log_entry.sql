DROP PROCEDURE IF EXISTS `sp_insert_log_entry`;

DELIMITER //
CREATE PROCEDURE `sp_insert_log_entry`(IN sp_device_name varchar(45), IN sp_idmessage text, IN sp_values varchar(255), IN sp_status_code varchar(15), IN sp_user varchar(45))
BEGIN
    insert into logs (`device_name`, `messages_idmessages`, `values`, `status_code`, `insert_timestamp`, `insert_user`, `modify_timestamp`, `modify_user`)
    values (sp_device_name, sp_idmessage, sp_values, sp_status_code, now(), sp_user, now(), sp_user);
END//
DELIMITER ;