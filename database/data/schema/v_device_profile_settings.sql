DROP VIEW IF EXISTS `v_device_profile_settings`;
CREATE VIEW `v_device_profile_settings` AS select `dps`.`iddevice_profile_settings` AS `iddevice_profile_settings`,`dps`.`device_profiles_iddevice_profiles` AS `device_profiles_iddevice_profiles`,`dps`.`setting_categorie_name` AS `setting_categorie_name`,`dps`.`setting_name` AS `setting_name`,`dps`.`value` AS `value`,`dps`.`modify_timestamp` AS `modify_timestamp` from (`device_profile_settings` `dps` join `device_profiles` `dp` on((`dps`.`device_profiles_iddevice_profiles` = `dp`.`iddevice_profiles`)));

