USE `verwaltungskonsole_v1`;
DROP procedure IF EXISTS `sp_update_command_jobs`;

DELIMITER $$
USE `verwaltungskonsole_v1`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_update_command_jobs`(OUT sp_result int, IN sp_user varchar(45), IN sp_idcommand_jobs int, IN sp_status varchar(7), IN sp_message text)
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 04.12.2015
    --  Last change : 04.12.2015
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We update the command jobs and insert some
    --                logs.
    --
    --  04.12.2015  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------

    -- declare some variables
    declare vdevice_name varchar(45);
    declare vc_description text;
    declare v_message text;
    declare vc_command_name varchar(45);
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
    
    -- getting data
    set vdevice_name = (select device_name from v_command_jobs where idcommand_jobs = sp_idcommand_jobs limit 1);
    set vc_command_name = (select command_name from v_command_jobs where idcommand_jobs = sp_idcommand_jobs limit 1);

    -- We have to check which status the job has
    IF sp_status = 'success' THEN
        -- update the job
        update command_jobs
        set state = 'success', modify_timestamp = now(), modify_user = sp_user
        where idcommand_jobs = sp_idcommand_jobs;
              
        -- check whether the update was successful
        IF code = '00000' THEN
            -- insert was successfull
            set sp_result = 1;
        
            -- insert a log entry
            set v_message = (SELECT CONCAT(vc_command_name, '#', 'success'));
            call sp_insert_log_entry('', 27, v_message, 'success', sp_user);
        ELSE
            -- insert failed
            set sp_result = 0;
        
            -- now we can write a log
            -- info for user
            set v_message = (SELECT CONCAT(sp_idcommand_jobs, '#', vc_command_name));
            call sp_insert_log_entry('', 28, v_message, 'failed', sp_user);
        
            -- debugging
            set v_message = (SELECT CONCAT(vc_command_name, '#', code, '#', msg));
            call sp_insert_log_entry('', 29, v_message, 'failed', sp_user);
        END IF;
        
    ELSEIF sp_status = 'failed' THEN
    
        -- update the job 
        update command_jobs
        set state = 'failed', modify_timestamp = now(), modify_user = sp_user
        where idcommand_jobs = sp_idcommand_jobs;
        
        -- check whether the update was successful
        IF code = '00000' THEN
            -- update was successfull
            set sp_result = 1;
        
        
            -- insert a log entry
            set v_message = (SELECT CONCAT(vc_command_name, '#', 'failed'));
            call sp_insert_log_entry('', 27, vc_command_name, 'failed', sp_user);
            
            -- job failed
            set v_message = (SELECT CONCAT(sp_idcommand_jobs, '#', vc_command_name, '#', vdevice_name));
            call sp_insert_log_entry('', 67, v_message, 'failed', sp_user);
            
            -- set debugging information for failed job.
            set v_message = (SELECT CONCAT(sp_idcommand_jobs, '#', sp_message));
            call sp_insert_log_entry('', 68, v_message, 'failed', sp_user);
        ELSE
            -- update failed
            set sp_result = 0;
        
            -- now we can write a log
            -- info for user
            call sp_insert_log_entry('', 69, sp_idcommand_jobs, 'failed', sp_user);
        
            -- debugging
            set v_message = (SELECT CONCAT(sp_idcommand_jobs, '#', code, '#', msg));
            call sp_insert_log_entry('', 70, v_message, 'failed', sp_user);
        END IF;
            
    ELSE
        -- status = pending
        -- update the job 
        update command_jobs
        set state = 'pending', modify_timestamp = now(), modify_user = sp_user
        where idcommand_jobs = sp_idcommand_jobs;
        
        -- check whether the update was successful
        IF code = '00000' THEN
            -- update was successfull
            set sp_result = 1;
        
            -- prepare message for logging
            set v_message = (SELECT CONCAT(vc_command_name, '#', 'pending'));
        
            -- insert a log entry
            call sp_insert_log_entry('', 27, v_message, 'success', sp_user);
            
            -- job pending
            set v_message = (SELECT CONCAT(vc_command_name, '#', vdevice_name));
            call sp_insert_log_entry('', 71, v_message, 'pending', sp_user);
        ELSE
            -- update failed
            set sp_result = 0;
        
            -- now we can write a log
            -- info for user
			call sp_insert_log_entry('', 69, sp_idcommand_jobs, 'failed', sp_user);
        
            -- debugging
            set v_message = (SELECT CONCAT(sp_idcommand_jobs, '#', code, '#', msg));
            call sp_insert_log_entry('', 70, v_message, 'failed', sp_user);
        END IF;        
        
    END IF;

END$$

DELIMITER ;


