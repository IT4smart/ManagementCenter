CREATE DEFINER=`root`@`%` PROCEDURE `sp_insert_device_profiles`(OUT sp_result int, IN sp_profile_name varchar(45), IN sp_description text, IN sp_state int, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 09.12.2015
    --  Last change : 09.12.2015
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the device
    --                profile created
    --
    --  09.12.2015  : Created
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
        
    insert into device_profiles (profile_name, description, state, insert_timestamp, insert_user, modify_timestamp, modify_user)
    values (sp_profile_name, sp_description, sp_state, now(), sp_user, now(), sp_user);
    
    
    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
                
        -- now we can write a log
        call sp_insert_log_entry('', '15', sp_profile_name, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        call sp_insert_log_entry('', '16', sp_profile_name, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_profile_name, '#', code, '#', msg));
        call sp_insert_log_entry('', '17', v_message, 'failed', sp_user);
    end if;    
END