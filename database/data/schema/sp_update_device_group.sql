CREATE DEFINER=`root`@`%` PROCEDURE `sp_update_device_group`(OUT sp_result INT, IN sp_group_id int, IN sp_group_name varchar(45), IN sp_description text, IN sp_state int, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 30.01.2016
    --  Last change : 30.01.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the device 
    --                group is updated
    --
    --  30.01.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    
   
    -- declare variable
    declare v_message text;
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
      
    update device_groups 
    set device_group_name = sp_group_name, description = sp_description, state = sp_state, modify_timestamp = now(), modify_user = sp_user
    where iddevice_groups = sp_group_id;
      
    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- now we can write a log
        call sp_insert_log_entry('', '46', sp_group_name, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        call sp_insert_log_entry('', '47', sp_group_name, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_group_name, '#', code, '#', msg));
        call sp_insert_log_entry('', '48', v_message, 'failed', sp_user);
    end if;    

END