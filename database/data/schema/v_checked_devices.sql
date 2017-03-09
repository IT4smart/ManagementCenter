DROP VIEW IF EXISTS `v_checked_devices`;
CREATE VIEW `v_checked_devices` AS select `d`.`device_name` AS `device_name`,`d`.`iddevice` AS `iddevice`,`d2dg`.`device_groups_iddevice_groups` AS `device_groups_iddevice_groups` from (`device` `d` left join `devices_to_device_groups` `d2dg` on((`d2dg`.`device_iddevice` = `d`.`iddevice`)));
