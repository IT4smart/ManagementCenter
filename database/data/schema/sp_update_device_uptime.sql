CREATE DEFINER=`root`@`%` PROCEDURE `sp_update_device_uptime`(OUT sp_result int, IN sp_iddevice int, IN sp_name varchar(45), IN sp_value varchar(45), IN sp_jobid varchar(5), IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2016
    -- ------------------------------------------------------------
    --  Created     : 28.09.2016
    --  Last change : 28.09.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the device updated
    --
    --  28.09.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------

    -- declare variable
    declare v_message text;
    declare v_device_name varchar(45);
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
      
    -- we update state of the device
    update device_performance_data
    set value = sp_value, modify_timestamp = now(), modify_user = sp_user
    where name = sp_name and device_iddevice = sp_iddevice;
    
    -- we update the last_check value
    update device_performance_data
    set value_date = now(), modify_timestamp = now(), modify_user = sp_user
    where name = 'last_check' and device_iddevice = sp_iddevice;
    
    
    set v_device_name = (SELECT device_name from device where iddevice = sp_iddevice);
    

    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- set job done
        call sp_update_command_jobs(@out, 'agent', sp_jobid, 'success', '');
        
        -- now we can write a log
        set v_message = (SELECT CONCAT(v_device_name, '#', sp_value));
        call sp_insert_log_entry('', 74, v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        call sp_insert_log_entry('', 75, v_device_name, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(v_device_name, '#', code, '#', msg));
        call sp_insert_log_entry('', 76, v_message, 'failed', sp_user);
    end if;    
END