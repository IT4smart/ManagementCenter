CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `v_device_summary_device_profiles` AS select `d`.`device_name` AS `device_name`,`dp`.`profile_name` AS `profile_name`,`dp2dg`.`modify_timestamp` AS `modify_timestamp` from (((`device` `d` join `devices_to_device_groups` `d2dg` on((`d`.`iddevice` = `d2dg`.`device_iddevice`))) join `device_profiles_to_device_groups` `dp2dg` on((`d2dg`.`device_groups_iddevice_groups` = `dp2dg`.`device_groups_iddevice_groups`))) join `device_profiles` `dp` on((`dp2dg`.`device_profiles_iddevice_profiles` = `dp`.`iddevice_profiles`)))