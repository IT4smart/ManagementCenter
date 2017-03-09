DROP PROCEDURE IF EXISTS `sp_delete_device_profile_settings`;

DELIMITER //
CREATE PROCEDURE `sp_delete_device_profile_settings`(OUT sp_result int, IN sp_iddevice_profile int, IN sp_categorie varchar(45), IN sp_setting_name varchar(45), IN sp_user varchar(45))
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
    
END//
DELIMITER ;