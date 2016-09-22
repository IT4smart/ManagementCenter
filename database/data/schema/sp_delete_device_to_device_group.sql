CREATE DEFINER=`root`@`%` PROCEDURE `sp_delete_device_to_device_group`(OUT sp_result int, IN sp_iddevice int, sp_iddevice_group int, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 09.12.2015
    --  Last change : 09.12.2015
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, after the device to 
    --                device group deleted. It's not possible to
    --                update such assingment.
    --
    --  09.12.2015  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    
   
    -- declare variable
    declare v_message text;
    declare v_device_name varchar(45);
    declare v_device_group varchar(45);
    DECLARE v_code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1
                v_code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;
        
    delete from `devices_to_device_groups` where `device_iddevice` = sp_iddevice and `device_groups_iddevice_groups` = sp_iddevice_group;
    
    -- get data for logs
    set v_device_name = (select `device_name` from `device` where `iddevice` = sp_iddevice);
    set v_device_group = (select `device_group_name` from `device_groups` where `iddevice_groups` = sp_iddevice_group);
    
    -- check whether the insert was successful
    IF v_code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- prepare message for logging
        set v_message = (SELECT CONCAT(v_device_name, '#', v_device_group));
        
        -- now we can write a log
        call sp_insert_log_entry(v_device_name, '36', v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        set v_message = (SELECT CONCAT(v_device_name, '#', v_device_group));
        call sp_insert_log_entry(v_device_name, '37', v_message, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(v_device_name, '#', v_device_group, '#', v_code, '#', msg));
        call sp_insert_log_entry(v_device_name, '38', v_message, 'failed', sp_user);
    end if;  
END