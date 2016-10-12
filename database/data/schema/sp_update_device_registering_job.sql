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
END