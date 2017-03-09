DROP PROCEDURE IF EXISTS `sp_delete_device_profiles_to_device_groups`;

DELIMITER //
CREATE PROCEDURE `sp_delete_device_profiles_to_device_groups`(OUT sp_result int, IN sp_idprofile int, IN sp_idgroup int, IN sp_user varchar(45))
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

END//
DELIMITER ;