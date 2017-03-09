DROP PROCEDURE IF EXISTS `sp_insert_device_to_register`;

DELIMITER //
CREATE PROCEDURE `sp_insert_device_to_register`(OUT sp_result int, IN sp_mac varchar(45), IN sp_hostname varchar(45), IN sp_user varchar(45))
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
END//
DELIMITER ;