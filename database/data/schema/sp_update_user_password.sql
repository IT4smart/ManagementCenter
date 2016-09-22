CREATE DEFINER=`root`@`%` PROCEDURE `sp_update_user_password`(OUT sp_result int, IN sp_iduser int, IN sp_password varchar(90), IN sp_user varchar(45))
BEGIN
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    --                  Copyright by IT4S GmbH 2015
    -- ------------------------------------------------------------
    --  Created     : 24.12.2015
    --  Last change : 21.02.2016
    --  Version     : 1.0
    --  Author      : Raphael Lekies (IT4S)
    --  Description : We insert log entries, atfer the user passsword
	--  			  updated
    --
    --  24.12.2015  : Created
    --  21.02.2016	: Change to only update users password.
    --
    -- ------------------------------------------------------------
    -- ------------------------------------------------------------
    
   
    -- declare variable
    declare v_message text;
	declare v_username varchar(45);
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


    update users 
    set password = sp_password, modify_timestamp = now(), modify_user = sp_user
    where idusers = sp_iduser;

	set v_username = (SELECT username FROM users WHERE idusers = sp_iduser);

    -- check whether the insert was successful
    IF code = '00000' THEN
        -- insert was successfull
        set sp_result = 1;
        
        -- now we can write a log
        call sp_insert_log_entry('', '5', v_username, 'success', sp_user);
        
    else
        -- insert failed
        set sp_result = 0;

        call sp_insert_log_entry('', '6', v_username, 'failed', sp_user);
        
        -- debugging
        set v_message = (SELECT CONCAT(v_username, '#', code, '#', msg));
        call sp_insert_log_entry('', '7', v_message, 'failed', sp_user);
    end if;


END