CREATE EVENT `scheduled_task_planner` ON SCHEDULE EVERY 1 MINUTE STARTS '2017-01-31 18:59:04' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    -- declare cursor
    declare v_id int;
    declare v_start_date datetime;
    declare v_end_date datetime;
    declare v_minute varchar(45);
    declare v_hour varchar(45);
    declare v_time varchar(45);
    declare v_day_of_month varchar(45);
    declare v_month varchar(45);
    declare v_weekday varchar(45);
    declare v_next_run datetime;
    declare v_temp int;
    declare v_message varchar(200);
    DECLARE no_more_rows BOOLEAN;
    declare stp_cursor cursor for 
    
    -- get all head information of the scheduled tasks
    select distinct(`idscheduled_tasks`), `start_date`, `end_date`, `minute`, `hour`, `day_of_month`, `month`, `weekday`, `next_run` from `v_scheduled_tasks_jobs` where `state` = 'activated' and `start_date` <= now() and (`end_date` >= now() or `end_date` is null) and (`next_run` <= now() or `next_run` is null);

    -- Declare 'handlers' for exceptions
	DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET no_more_rows = TRUE;
    
    open stp_cursor;
    
    get_data: LOOP
		FETCH stp_cursor INTO v_id, v_start_date, v_end_date, v_minute, v_hour, v_day_of_month, v_month, v_weekday, v_next_run;
    
		IF no_more_rows THEN
			LEAVE get_data;
		END IF;
        
        -- start with the current time as the next runtime
        set v_next_run = now();
        
        -- 
        -- MINUTES 
        --
        
        -- check if the task is running every 'n' minutes
        set v_temp = (SELECT LOCATE('/', v_minute));
        
        IF v_temp > 0 THEN
			-- get the minutes
            set v_temp = v_temp + 1;
			set v_minute = (SELECT SUBSTRING(v_minute, v_temp));
            
            -- set a new time to run this task
			set v_next_run = DATE_ADD(v_next_run, INTERVAL v_minute MINUTE);
		ELSE
			-- we had to add to the new runtime only some minutes
            IF v_minute <> '*' THEN
				set v_next_run = DATE_ADD(v_next_run, INTERVAL v_minute MINUTE);
			END IF;
        END IF;
        
        
        --
        -- HOURS 
        --
        
        -- check if the task is running every 'n' hours
        set v_temp = (SELECT LOCATE('/', v_hour));
        
        IF v_temp > 0 THEN
			-- get the minutes
            set v_temp = v_temp + 1;
			set v_hour = (SELECT SUBSTRING(v_hour, v_temp));
            
            -- set a new time to run this task
			set v_next_run = DATE_ADD(v_next_run, INTERVAL v_hour HOUR);
		ELSE
			-- we had to add to the new runtime only some minutes
            IF v_hour <> '*' THEN
				set v_next_run = DATE_ADD(v_next_run, INTERVAL v_hour HOUR);
			END IF;
        END IF;
        
        
        -- If the task has a specific time to run.
        IF (SELECT LOCATE('/', v_minute)) = 0 && (SELECT LOCATE('/', v_hour)) = 0 THEN
			set v_time = (SELECT CONCAT(v_hour, ':', v_minute, ':00'));
			set v_next_run = (SELECT CONCAT_WS(' ', DATE(v_next_run), v_time));
        END IF;
        
        
        --
        -- Day of month
        --
        
        -- check if the task is running every 'n' days
        set v_temp = (SELECT LOCATE('/', v_day_of_month));
        
        IF v_temp > 0 THEN
			-- get the minutes
            set v_temp = v_temp + 1;
			set v_day_of_month = (SELECT SUBSTRING(v_day_of_month, v_temp));
            
            -- set a new time to run this task
			set v_next_run = DATE_ADD(v_next_run, INTERVAL v_day_of_month DAY);
		ELSE
			IF v_day_of_month = '*' THEN
				set v_next_run = DATE_ADD(v_next_run, INTERVAL 1 DAY);
            END IF;
        END IF;
        
        
        --
        -- Get all details of the job and insert them into the command_jobs table
        --
        Block2: BEGIN
	    declare v_deviceid int;
	    declare v_idcommand int;
		declare v_cnt_loop int;
        declare v_cnt_result int;
        declare v_device varchar(45);
        declare v_command_name varchar(45);
	    DECLARE no_more_rows2 BOOLEAN;
	    declare detail_cursor cursor for
	    select `device_iddevice`, `idcommands` from `v_scheduled_tasks_jobs` where `idscheduled_tasks` = v_id;

            -- Declare 'handlers' for exceptions
	    DECLARE CONTINUE HANDLER FOR NOT FOUND
	    SET no_more_rows2 = TRUE;        

	    open detail_cursor;
    
	    -- set counter to 0
	    set v_cnt_loop = 0;
            set v_cnt_result = 0;
            
            -- get information for logging
            set v_device = (SELECT `device_name` from device where `iddevice` = v_deviceid);
            set v_command_name = (SELECT `command_name` from commands where `idcommands` = v_idcommand);
    
	    get_detail_data: LOOP
			FETCH detail_cursor INTO v_deviceid, v_idcommand;

			IF no_more_rows2 THEN
				LEAVE get_detail_data;
			END IF;
        
				-- insert job
				call sp_insert_command_jobs(@out, v_idcommand, v_deviceid, NULL, NULL, 'event_scheduler');
                
                set v_message = (SELECT CONCAT(v_command_name, '#', v_device));
                
                IF (SELECT @out) = 1 THEN
					call sp_insert_log_entry('', 64, v_message, 'success', 'event_scheduler');
				ELSE
					call sp_insert_log_entry('', 65, v_message, 'success', 'event_scheduler');
                END IF;
                
                set v_cnt_loop = v_cnt_loop + 1;
                set v_cnt_result = v_cnt_result + (SELECT @out);
        
			END LOOP get_detail_data;
            close detail_cursor;
            
            -- at the end we check if we insert all devices
            IF v_cnt_loop = v_cnt_result THEN
				update scheduled_tasks set next_run = v_next_run, modify_timestamp = now(), modify_user = 'event_scheduler' where idscheduled_tasks = v_id;
            END IF;
            
        END Block2;
        
    END LOOP get_data;
    
    close stp_cursor;


END