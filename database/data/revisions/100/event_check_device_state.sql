DELIMITER //
CREATE EVENT IF NOT EXISTS check_device_state
ON SCHEDULE EVERY 1 MINUTE
STARTS CURRENT_TIMESTAMP
DO BEGIN
    -- declare cursor
    declare v_state varchar(7);
    declare v_date datetime;
    declare v_diff int;
    declare v_deviceid int;
    declare v_device varchar(45);
    declare v_message varchar(200);
    DECLARE no_more_rows BOOLEAN;
    declare state_cursor cursor for 
    select `value`, `modify_timestamp`, `device_iddevice` from `v_device_performance_data` where `name` = 'state' and `value` = 'online';
	
    -- Declare 'handlers' for exceptions
	DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET no_more_rows = TRUE;
    
    open state_cursor;
    
    get_data: LOOP
		FETCH state_cursor INTO v_state, v_date, v_deviceid;
    
		IF no_more_rows THEN
			LEAVE get_data;
		END IF;
        
        set v_diff = (SELECT TIMESTAMPDIFF(MINUTE, v_date, now()));
		set v_device = (SELECT `device_name` from `device` where `iddevice` = v_deviceid);
        
        set v_message = (SELECT CONCAT(v_device, '#', v_diff));
        call sp_insert_log_entry('', 73, v_message, 'success', 'event_scheduler');
        
        IF v_diff > 5 THEN
			update `device_performance_data` set `value` = 'offline', `modify_timestamp` = now(), `modify_user` = 'event_scheduler' where `device_iddevice` = v_deviceid and `name` = 'state' and `device_iddevice` = v_deviceid;
			call sp_insert_log_entry('', 72, v_device, 'success', 'event_scheduler');
        END IF;
        
    END LOOP get_data;
    
    close state_cursor;

END //
DELIMITER ;
