DROP PROCEDURE IF EXISTS `sp_insert_command_jobs`;

DELIMITER //
CREATE PROCEDURE `sp_insert_command_jobs`(OUT sp_result int, IN sp_idcommands int, IN sp_iddevice int, IN sp_interval int, IN sp_payload text, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 04.12.2015
    --  Last change : 12.08.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We update the command jobs and insert some
    --                logs.
    --
    --  04.12.2015  : Created
    --  12.08.2016	: Logging auf die aktuellste Version gebracht.
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------

    -- declare variable
    declare v_message text;
    declare vdevice_name varchar(45);
    declare vc_description text;
    declare vc_command_name varchar(45);
    declare v_lid int;
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

	IF sp_interval > 0 then    
		insert into command_jobs (timestamp, state, payload, commands_idcommands, device_iddevice, insert_timestamp, insert_user, modify_timestamp, modify_user)
		values (DATE_ADD(now(), INTERVAL sp_interval MINUTE), NULL, sp_payload, sp_idcommands, sp_iddevice, now(), sp_user, now(), sp_user);
	ELSE
		insert into command_jobs (timestamp, state, payload, commands_idcommands, device_iddevice, insert_timestamp, insert_user, modify_timestamp, modify_user)
		values (now(), NULL, sp_payload, sp_idcommands, sp_iddevice, now(), sp_user, now(), sp_user);
    END IF;
    
	set v_lid = LAST_INSERT_ID();
        
	-- getting data
	set vdevice_name = (select device_name from v_command_jobs where idcommand_jobs = v_lid limit 1);
	set vc_command_name = (select command_name from v_command_jobs where idcommands = sp_idcommands limit 1);
    
    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
		set sp_result = 1;
        
        -- prepare message for logging
        set v_message = (SELECT CONCAT(vc_command_name, '#', vdevice_name));
        
        -- now we can write a log
        call sp_insert_log_entry('', 64, v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        set v_message = (SELECT CONCAT(vc_command_name, '#', vdevice_name));
        call sp_insert_log_entry('', 65, v_message, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(vc_command_name, '#', vdevice_name, '#', `code`, '#', msg));
        call sp_insert_log_entry('', 66, v_message, 'failed', sp_user);
    end if;
END//
DELIMITER ;