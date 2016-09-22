CREATE DEFINER=`root`@`%` TRIGGER command_jobs_AUDE AFTER UPDATE ON command_jobs FOR EACH ROW
BEGIN

declare new_time datetime;

set new_time = DATE_ADD(now(), INTERVAL 15 MINUTE);

IF NEW.state = 'failed' THEN
 BEGIN
    update command_jobs set modify_timestamp = now(), modify_user = 'trigger', timestamp = new_time, state = 'pending'
    where idcommand_jobs = old.idcommand_jobs;
 END;
END IF;
END