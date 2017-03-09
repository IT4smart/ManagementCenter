DROP VIEW IF EXISTS `v_dashboard_device_state`;
CREATE VIEW `v_dashboard_device_state` AS select count(`device`.`state`) AS `cnt_state`,`device`.`state` AS `state` from `device` group by `device`.`state`;
