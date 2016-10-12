CREATE DEFINER=`root`@`%` TRIGGER `verwaltungskonsole_v1`.`device_registering_jobs_AFTER_UPDATE` AFTER UPDATE ON `device_registering_jobs` FOR EACH ROW
BEGIN

	declare v_message text;
	set v_message = (SELECT CONCAT(OLD.`mac`, '#', OLD.`hostname`));

	IF NEW.`state` = 'working' THEN
		call sp_insert_log_entry('', 83, v_message, 'success', 'trigger');
	ELSEIF NEW.`state` = 'error' THEN
        call sp_insert_log_entry('', 84, v_message, 'failed', 'trigger');
	ELSEIF NEW.`state` = 'done' THEN
		call sp_insert_log_entry('', 85, v_message, 'success', 'trigger');
	ELSEIF NEW.`state` = 'wait_resp' THEN
		call sp_insert_log_entry('', 85, v_message, 'success', 'trigger');
	ELSE
		set v_message = (SELECT CONCAT(OLD.`mac`, '#', OLD.`state`));
        call sp_insert_log_entry('', 86, v_message, 'success', 'trigger');
    END IF;
END