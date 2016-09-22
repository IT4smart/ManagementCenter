CREATE DEFINER=`root`@`%` PROCEDURE `sp_update_device_state`(OUT sp_result int, IN sp_iddevice int, IN sp_state varchar(45), IN sp_ip_address varchar(45), IN sp_jobid int, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 12.08.2016
    --  Last change : 12.08.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the device updated
    --
    --  12.08.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------

    -- declare variable
    declare v_message text;
    declare v_device_name varchar(45);
    declare v_interval int;
    declare v_commandid int;
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
    set state = sp_state, ip_address = sp_ip_address, modify_timestamp = now(), modify_user = sp_user
    where iddevice = sp_iddevice;
    
    set v_device_name = (SELECT device_name from device where iddevice = sp_iddevice);
    

    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- set job done
        update command_jobs set state = 'success' where idcommand_jobs = sp_jobid;
        
        -- create a neew job if interval is not 0
        set v_interval = (SELECT `interval` from v_command_jobs where idcommand_jobs = sp_jobid);
        
        IF v_interval > 0 THEN
			set v_commandid = (SELECT `idcommands` from v_command_jobs where idcommand_jobs = sp_jobid);
			call sp_insert_command_jobs(v_commandid, sp_iddevice, v_interval, 'agent');
        END IF;
        
        -- now we can write a log
        set v_message = (SELECT CONCAT(v_device_name, '#', sp_state));
        call sp_insert_log_entry('', '61', v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        call sp_insert_log_entry('', '62', v_device_name, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(v_device_name, '#', code, '#', msg));
        call sp_insert_log_entry('', '63', v_message, 'failed', sp_user);
    end if;    
END