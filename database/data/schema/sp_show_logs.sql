DROP PROCEDURE IF EXISTS `sp_show_logs`;

DELIMITER //
CREATE PROCEDURE `sp_show_logs`(IN sp_device_name varchar(45), IN sp_locals varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 01.01.2016
    --  Last change : 01.01.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We prepare log for webfrontend
    --
    --  01.01.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
	 
	-- declare variable
	DECLARE Vlocals varchar(45);
	DECLARE Vdevice_name varchar(45);
	DECLARE Vstatus_code varchar(15);
	DECLARE Vmodify_user varchar(45);
	DECLARE Vmodify_timestamp datetime;
	DECLARE Vlevel varchar(5);
	DECLARE Vtext_translation text;
	DECLARE Vidlocales varchar(5);
	DECLARE Vvalues varchar(200);
	DECLARE finished INTEGER DEFAULT 0;
	DECLARE Vposition int;
	DECLARE Vpart_string varchar(200);
	DECLARE Vnew_text text;
	DECLARE stop int DEFAULT 0;

	-- prepare locals
	SET Vlocals = (SELECT CONCAT(sp_locals, '%'));
    
	-- create temp table as first
	CREATE TEMPORARY TABLE IF NOT EXISTS`tmp_logs` (
	`device_name` varchar(45) NULL,
	`status_code` varchar(15) NULL,
	`modify_user` varchar(45) NULL,
	`modify_timestamp` datetime NULL,
	`level` varchar(5) NULL,
	`text_translation` text NULL,
	`idlocales` varchar(5) NULL,
	`values` varchar(200) NULL
	);
    
    
    truncate table `tmp_logs`;

	-- declare cursor
    BEGIN     
	 DECLARE cursor_log CURSOR FOR
	 SELECT `device_name`, `status_code`, `modify_user`, `modify_timestamp`, `level`, `text_translation`, `idlocales`, `values` FROM v_logs 
	 WHERE 1=1
     AND (`idlocales` = sp_locals or `idlocales` = 'en_US')
	 AND CASE WHEN sp_device_name <> '' THEN `device_name` = sp_device_name ELSE ((`device_name` = '' or `device_name` = sp_device_name)) END;
     
	 -- declare NOT FOUND handler
	 DECLARE CONTINUE HANDLER FOR NOT FOUND SET stop = 1;

	 -- open cursor
	 OPEN cursor_log;

	 get_logs: LOOP
	 FETCH cursor_log INTO Vdevice_name, Vstatus_code, Vmodify_user, Vmodify_timestamp, Vlevel, Vtext_translation, Vidlocales, Vvalues;


	 IF stop = 1 
	 THEN 
	  BEGIN
	   LEAVE get_logs;
	  END;
	 END IF;

	 -- find the first '#'
	 WHILE stop = 0
	 DO
	  SET Vposition = (SELECT LOCATE('#', Vvalues));

      -- check if only one value is at this list.
	  IF Vposition = 0 
	  THEN
	   BEGIN
        SET Vnew_text = (SELECT CONCAT(REPLACE(LEFT(Vtext_translation, INSTR(Vtext_translation, '#')), '#', Vvalues), SUBSTRING(Vtext_translation, INSTR(Vtext_translation, '#') + 1)));
       END;
	  ELSE
       BEGIN
	    -- extract string
	    SET Vpart_string = (SELECT substring(Vvalues, 1, (Vposition - 1)));

	    -- set value in log text
	    SET Vnew_text = (SELECT CONCAT(REPLACE(LEFT(Vtext_translation, INSTR(Vtext_translation, '#')), '#', Vpart_string), SUBSTRING(Vtext_translation, INSTR(Vtext_translation, '#') + 1)));
 
	    -- remove part string vom origin
	    SET Vpart_string = (SELECT CONCAT(Vpart_string, '#'));
	    SET Vvalues = (SELECT REPLACE(Vvalues, Vpart_string, ''));
       END;
	  END IF;
      
	  -- if we find no other '#', then the locate function returns '0'
	  IF Vposition = 0 
	  THEN
	   BEGIN
		SET stop = 1;
  
		-- insert that log entry in tmp table
		INSERT INTO tmp_logs (`device_name`, `status_code`, `modify_user`, `modify_timestamp`, `level`, `text_translation`, `idlocales`, `values`)
		VALUES (Vdevice_name, Vstatus_code, Vmodify_user, Vmodify_timestamp, Vlevel, Vnew_text, Vidlocales, Vvalues);
	   END;
	  END IF;
	 END WHILE;

	 END LOOP get_logs;
 
	 CLOSE cursor_log;
   END;

 SELECT * FROM tmp_logs;
 DROP TABLE tmp_logs;
END//
DELIMITER ;