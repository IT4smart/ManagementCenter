DROP PROCEDURE IF EXISTS `sp_insert_usergroup`;

DELIMITER //
CREATE PROCEDURE `sp_insert_usergroup`(OUT sp_result int, IN sp_groupname varchar(45), IN sp_description text, IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 21.02.2016
    --  Last change : 21.02.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the usergroup created
    --
    --  21.02.2016  : Created
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
      
    -- insert usergroup
    insert into usergroups (group_name, description, insert_timestamp, insert_user, modify_timestamp, modify_user)
    values (sp_groupname, sp_description, now(), sp_user, now(), sp_user);

    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- now we can write a log
        call sp_insert_log_entry('', '55', sp_groupname, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;
        
        -- now we can write a log
        -- info for user
        call sp_insert_log_entry('', '56', sp_groupname, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(sp_groupname, '#', code, '#', msg));
        call sp_insert_log_entry('', '57', v_message, 'failed', sp_user);
    end if;
END//
DELIMITER ;