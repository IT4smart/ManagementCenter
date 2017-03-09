DROP VIEW IF EXISTS `v_dashboard_device_performance_data_state`;
CREATE VIEW `v_dashboard_device_performance_data_state` AS select count(`device_performance_data`.`value`) AS `cnt_value`,`device_performance_data`.`value` AS `value` from `device_performance_data` where ((1 = 1) and (`device_performance_data`.`name` = 'state')) group by `device_performance_data`.`value`;
