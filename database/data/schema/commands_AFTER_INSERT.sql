CREATE TRIGGER `verwaltungskonsole_v1`.`commands_AFTER_INSERT` AFTER INSERT ON `commands` FOR EACH ROW
BEGIN
	declare v_id int;
	DECLARE no_more_rows BOOLEAN;
	declare commands_cursor cursor for select `iddevice` from device where `state` = 'activated';
    
    
    -- Declare 'handlers' for exceptions
	DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET no_more_rows = TRUE;

	open commands_cursor;
    
    get_data: LOOP
		FETCH commands_cursor INTO v_id;
        
        IF no_more_rows THEN
			LEAVE get_data;
		END IF;
        
        IF NEW.`interval` > 0 THEN
			call sp_insert_command_jobs(@out, NEW.`idcommands`, v_id, NEW.`interval`, '', 'trigger');
		END IF;
        
	END LOOP get_data;
    
    close commands_cursor;
END 