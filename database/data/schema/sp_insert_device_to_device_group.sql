DROP PROCEDURE IF EXISTS `sp_insert_device_to_device_group`;

DELIMITER //
CREATE PROCEDURE `sp_insert_device_to_device_group`(OUT sp_result int, IN sp_iddevice int, IN sp_iddevice_group int, IN sp_user varchar(45))
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

END//
DELIMITER ;