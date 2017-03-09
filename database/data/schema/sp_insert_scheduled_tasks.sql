DROP PROCEDURE IF EXISTS `sp_insert_scheduled_tasks`;

DELIMITER //
CREATE PROCEDURE `sp_insert_scheduled_tasks`(OUT sp_result int, IN sp_task_name varchar(45), IN sp_description varchar(200), IN sp_state varchar(45), IN sp_start_date datetime, IN sp_end_date datetime, IN sp_minute varchar(45), IN sp_hour varchar(45), IN sp_day_of_month varchar(45), IN sp_month varchar(45), IN sp_weekday varchar(45), IN sp_idcommand int, IN sp_device_groups varchar(200), IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2016
    -- ------------------------------------------------------------
    --  Created     : 14.10.2016
    --  Last change : 14.10.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert new scheduled tasks and insert also
    --                some logs.
    --
    --  14.10.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------

    -- declare variable
    declare v_message text;
    DECLARE stop int DEFAULT 0;
    DECLARE Vposition int;
    DECLARE Vpart_string varchar(200);
    DECLARE Vnew_text text;
    declare v_lid int;
    declare vc_command_name varchar(45);
    declare vdevice_name varchar(45);
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
        
	INSERT INTO scheduled_tasks (`task_name`, `description`, `state`, `start_date`, `end_date`, `minute`, `hour`, `day_of_month`, `month`, `weekday`, `commands_idcommands`, `insert_timestamp`, `insert_user`, `modify_timestamp`, `modify_user`)
    VALUES (sp_task_name, sp_description, sp_state, sp_start_date, sp_end_date, sp_minute, sp_hour, sp_day_of_month, sp_month, sp_weekday, sp_idcommand, now(), sp_user, now(), sp_user);
    
    set v_lid = LAST_INSERT_ID();
    
    
	-- find the first '#'
	WHILE stop = 0
	 DO
	  SET Vposition = (SELECT LOCATE('#', sp_device_groups));

      -- check if only one value is at this list or it's the last one.
	  IF Vposition = 0 
	  THEN
	   BEGIN
		SET stop = 1;
        insert into scheduled_tasks_to_device_groups (`scheduled_tasks_idscheduled_tasks`, `device_groups_iddevice_groups`, `insert_timestamp`, `insert_user`, `modify_timestamp`, `modify_user`)
        VALUES( v_lid, sp_device_groups, now(), sp_user, now(), sp_user);
	   END;
	  ELSE
       BEGIN
	    -- extract string
	    SET Vpart_string = (SELECT substring(sp_device_groups, 1, (Vposition - 1)));

	    -- set value in log text
	    insert into scheduled_tasks_to_device_groups (`scheduled_tasks_idscheduled_tasks`, `device_groups_iddevice_groups`, `insert_timestamp`, `insert_user`, `modify_timestamp`, `modify_user`)
        VALUES( v_lid, Vpart_string, now(), sp_user, now(), sp_user);
        
	    -- remove part string vom origin
	    SET Vpart_string = (SELECT CONCAT(Vpart_string, '#'));
	    SET sp_device_groups = (SELECT REPLACE(sp_device_groups, Vpart_string, ''));
       END;
	  END IF;
	 END WHILE;

	-- get information for logging
    set vc_command_name = (SELECT `commmand_name` from commands where `idcommands` = sp_idcommand);

    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
		set sp_result = 1;
        
        -- prepare message for logging
        set v_message = (SELECT CONCAT(sp_task_name, '#', vc_command_name));
        
        -- now we can write a log
        call sp_insert_log_entry('', 89, v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        set v_message = (SELECT CONCAT(sp_task_name, '#', vc_command_name));
        call sp_insert_log_entry('', 90, v_message, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_task_name, '#', vc_command_name, '#', `code`, '#', msg));
        call sp_insert_log_entry('', 91, v_message, 'failed', sp_user);
    end if;    
END//
DELIMITER ;