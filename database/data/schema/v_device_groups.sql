CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `v_device_groups` AS select `device_groups`.`iddevice_groups` AS `iddevice_groups`,`device_groups`.`device_group_name` AS `device_group_name`,`device_groups`.`description` AS `description`,`device_groups`.`state` AS `state`,`device_groups`.`insert_timestamp` AS `insert_timestamp`,`device_groups`.`insert_user` AS `insert_user`,`device_groups`.`modify_timestamp` AS `modify_timestamp`,`device_groups`.`modify_user` AS `modify_user` from `device_groups`