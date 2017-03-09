DROP PROCEDURE IF EXISTS `sp_update_user_usergroup`;

DELIMITER //
CREATE PROCEDURE `sp_update_user_usergroup`(OUT sp_result int, IN sp_iduser int, IN sp_usergroup int, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 21.02.2016
    --  Last change : 21.02.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer update user to
    --  			  usergroup
    --
    --  21.02.2016  : Created
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
     -- declare variable
    declare v_message text;
    declare v_usergroup varchar(45);
    declare v_username varchar(45);
    declare v_before_usergroup varchar(45);
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


	-- get usergroup before update
    set v_before_usergroup = (SELECT group_name FROM v_users WHERE idusers = sp_iduser);
      
    -- update users_to_usergroups
    update users_to_usergroups set usergroups_idusergroups = sp_usergroup, modify_timestamp = now(), modify_user = sp_user where users_idusers = sp_iduser;

	-- get new usergroup
	set v_usergroup = (SELECT group_name FROM usergroups WHERE idusergroups = sp_usergroup);
    
    -- get username
    set v_username = (SELECT username FROM users WHERE idusers = sp_iduser);
    

    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- now we can write a log
        set v_message = (SELECT CONCAT(v_username, '#', v_before_usergroup, '#', v_usergroup)); 
        call sp_insert_log_entry('', '58', v_message, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        
        call sp_insert_log_entry('', '59', v_usergroup, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(v_usergroup, '#', code, '#', msg));
        call sp_insert_log_entry('', '60', v_message, 'failed', sp_user);
    end if;   
END//
DELIMITER ;