DROP PROCEDURE IF EXISTS `sp_insert_user`;

DELIMITER //
CREATE PROCEDURE `sp_insert_user`(OUT sp_result int, IN sp_usergroup_id int, IN sp_username varchar(45), IN sp_password varchar(90), IN sp_email varchar(45), IN sp_state int, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 04.12.2015
    --  Last change : 21.02.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the user created
    --
    --  04.12.2015  : Created
    --  21.02.2016	: Also insert user to usergroup
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    
   
    -- declare variable
    declare v_message text;
    declare lid int; -- last inserted id from table 'users'
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


    insert into users (username, password, email, state, insert_timestamp, insert_user, modify_timestamp, modify_user)
    values (sp_username, sp_password, sp_email, sp_state, now(), sp_user, now(), sp_user);
    
	-- get latest inserted id from table 'users'
    set lid = last_insert_id();
    
    -- insert user and usergroup
    insert into users_to_usergroups (users_idusers, usergroups_idusergroups, insert_timestamp, insert_user, modify_timestamp, modify_user)
    values (lid, sp_usergroup_id, now(), sp_user, now(), sp_user);
    

    -- check whether the insert was successful
    IF code = '00000' THEN
     BEGIN
        -- insert was successfull
        set sp_result = 1;
        
        -- now we can write a log
        call sp_insert_log_entry('', '1', sp_username, 'success', sp_user);
	 END;
        
    else
     BEGIN
        -- insert failed
        set sp_result = 0;

        call sp_insert_log_entry('', '2', sp_username, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_username, '#', code, '#', msg));
        call sp_insert_log_entry('', '3', v_message, 'failed', sp_user);
	 END;
    end if;
    
END//
DELIMITER ;