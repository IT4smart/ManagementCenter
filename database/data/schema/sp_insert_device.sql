CREATE DEFINER=`root`@`%` PROCEDURE `sp_insert_device`(OUT sp_result int, IN sp_device_name varchar(45), IN sp_mac_address varchar(45), IN sp_ip_address varchar(45), IN sp_serialnumber varchar(45), IN sp_note text, IN sp_device_type int, IN sp_device_group int, IN sp_photo varchar(255), IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 07.12.2015
    --  Last change : 07.12.2015
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the device created
    --
    --  07.12.2015  : Created
    --	11.08.2016	: Add insert for command job
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    
   
    -- declare variable
    declare v_message text;
    declare lid int; -- last inserted id from table 'device'
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
      
    -- insert device
    insert into device (device_types_iddevice_types, device_name, mac_address, ip_address, serialnumber, note, device_photo, insert_timestamp, insert_user, modify_timestamp, modify_user)
    values (sp_device_type, sp_device_name, sp_mac_address, sp_ip_address, sp_serialnumber, sp_note, sp_photo, now(), sp_user, now(), sp_user);

    -- get latest inserted id from table 'device'
    set lid = last_insert_id();

    -- insert device and group
    insert into devices_to_device_groups (device_iddevice, device_groups_iddevice_groups, insert_timestamp, insert_user, modify_timestamp, modify_user)
    values (lid, sp_device_group, now(), sp_user, now(), sp_user);
    
    -- insert job for getting state of the device
    insert into command_jobs (timestamp, state, insert_timestamp, insert_user, modify_timestamp, modify_user, commands_idcommands, device_iddevice) 
    values (now(), '', now(), sp_user, now(), sp_user, 2, lid);


    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- now we can write a log
        call sp_insert_log_entry('', '8', sp_device_name, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        call sp_insert_log_entry('', '9', sp_device_name, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_device_name, '#', code, '#', msg));
        call sp_insert_log_entry('', '10', v_message, 'failed', sp_user);
    end if;

END