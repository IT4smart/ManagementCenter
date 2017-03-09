CREATE EVENT `register_device` ON SCHEDULE EVERY 1 MINUTE STARTS '2016-10-08 21:57:41' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
	-- declare variables
    declare v_id int;
    declare v_mac varchar(45);
    declare v_temp_mac varchar(45);
    declare v_hostname varchar(45);
    declare v_group varchar(45);
    declare v_groupid int;
    declare v_device_type_id int;
	DECLARE no_more_rows BOOLEAN;
	declare device_cursor cursor for
	select `iddevice_registering_jobs`, `mac`, `hostname`, `group` from v_device_registering_jobs 
	where 1=1
	and `timestamp` <= now()
	and `state` = 'new';

	-- Declare 'handlers' for exceptions
	DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET no_more_rows = TRUE;

	open device_cursor;

	get_data: LOOP
		FETCH device_cursor INTO v_id, v_mac, v_hostname, v_group;
        
        IF no_more_rows THEN
			LEAVE get_data;
		END IF;
        
		-- set job to pending
		update device_registering_jobs set `state` = 'working', `modify_timestamp` = now(), `modify_user` = 'event_scheduler' where iddevice_registering_jobs = v_id;

		-- at first we should check if there is any other device with the same mac address
		set v_temp_mac = (SELECT `mac_address` FROM `v_devices` where `mac_address` = v_mac limit 1);

	IF v_temp_mac is null or v_temp_mac = '' THEN
        	set v_groupid = (SELECT iddevice_groups FROM device_groups where device_group_name = v_group);
        	set v_device_type_id = (select iddevice_types from device_types where device_type_name = (SELECT device_type from v_device_registering_jobs where iddevice_registering_jobs = v_id));
        	call sp_insert_device (@out, v_hostname, v_mac, '', '', v_device_type_id, v_groupid, '', 'event_scheduler');
    
		if @out = 1 then
			update device_registering_jobs set `state` = 'wait_resp', `modify_timestamp` = now(), `modify_user` = 'event_scheduler' where iddevice_registering_jobs = v_id;
		else
			update device_registering_jobs set `state` = 'error', `modify_timestamp` = now(), `modify_user` = 'event_scheduler' where iddevice_registering_jobs = v_id;
		end if;
	ELSE
		update device_registering_jobs set `state` = 'error', `modify_timestamp` = now(), `modify_user` = 'event_scheduler';
		call sp_insert_log_entry('', 87, v_mac, 'success', 'event_scheduler');
	END IF;
    
	END LOOP get_data;
    
    close device_cursor;


END