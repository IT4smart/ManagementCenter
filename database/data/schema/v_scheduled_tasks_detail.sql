DROP VIEW IF EXISTS `v_scheduled_tasks_detail`;
CREATE VIEW `v_scheduled_tasks_detail` AS select `st`.`task_name` AS `task_name`,`st`.`description` AS `description`,`st`.`state` AS `state`,`st`.`start_date` AS `start_date`,`st`.`end_date` AS `end_date`,`st`.`minute` AS `minute`,`st`.`hour` AS `hour`,`st`.`day_of_month` AS `day_of_month`,`st`.`month` AS `month`,`st`.`weekday` AS `weekday`,`st`.`commands_idcommands` AS `commands_idcommands`,`st2dg`.`device_groups_iddevice_groups` AS `device_groups_iddevice_groups`,`d2dg`.`device_iddevice` AS `device_iddevice`,`d`.`device_name` AS `device_name`,`d`.`state` AS `device_state` from (((`scheduled_tasks` `st` join `scheduled_tasks_to_device_groups` `st2dg` on((`st`.`idscheduled_tasks` = `st2dg`.`scheduled_tasks_idscheduled_tasks`))) join `devices_to_device_groups` `d2dg` on((`st2dg`.`device_groups_iddevice_groups` = `d2dg`.`device_groups_iddevice_groups`))) join `device` `d` on((`d2dg`.`device_iddevice` = `d`.`iddevice`)));