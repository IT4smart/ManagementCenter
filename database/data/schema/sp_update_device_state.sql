DROP PROCEDURE IF EXISTS `sp_update_device_state`;

DELIMITER //
CREATE PROCEDURE `sp_update_device_state`(OUT sp_result int, IN sp_deviceid int, IN sp_state varchar(45), IN sp_user varchar(45))
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

END//
DELIMITER ;