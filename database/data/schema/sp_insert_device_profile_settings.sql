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
END