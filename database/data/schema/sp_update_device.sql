DROP PROCEDURE IF EXISTS `sp_update_device`;

DELIMITER //
CREATE PROCEDURE `sp_update_device`(OUT sp_result int, IN sp_iddevice int, IN sp_device_name varchar(45), IN sp_mac_address varchar(45), IN sp_ip_address varchar(45), IN sp_serialnumber varchar(45), IN sp_note text, IN sp_device_type int, IN sp_device_group int, IN sp_photo varchar(255), IN sp_user varchar(45))
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

END//
DELIMITER ;