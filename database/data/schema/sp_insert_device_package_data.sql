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
END