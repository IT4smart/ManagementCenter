CREATE TRIGGER `verwaltungskonsole_v1`.`device_AFTER_UPDATE` AFTER UPDATE ON `device` FOR EACH ROW
BEGIN

	declare v_idcommand int;
        declare v_interval int;
    
	-- insert jobs to collect data
	declare no_more_rows boolean;
	declare command_cursor cursor for select `idcommands`, `interval` from `commands` where `interval` > 0;
        
	-- Declare 'handlers' for exceptions
	DECLARE CONTINUE HANDLER FOR NOT FOUND
	SET no_more_rows = TRUE;

	IF NEW.`state` = 'activated' THEN
		-- insert tempalte for performance data
		insert into device_performance_data (`name`, `value`, `value_date`, `insert_timestamp`, `insert_user`, `modify_timestamp`, `modify_user`, `device_iddevice`)
        VALUES ('state', 'offline', null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
			('last_check', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('uptime', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('net_ip', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('net_speed', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('net_type', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('net_subnetmask', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('net_gateway', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('net_dns1', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('net_dns2', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('cpu_family', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('cpu_speed', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('cpu_cores', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('memory_total', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('memory_free', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('architecture', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice),
            ('kernel_version', null, null, now(), 'trigger', now(), 'trigger', OLD.iddevice);
            
		open command_cursor;
        
        get_data: LOOP
			FETCH command_cursor INTO v_idcommand, v_interval;
        
			IF no_more_rows THEN
				LEAVE get_data;
			END IF;
        
			call sp_insert_command_jobs(@out, v_idcommand, OLD.iddevice, v_interval, '', 'trigger');
		END LOOP get_data;
    
		close command_cursor;
    END IF;
END