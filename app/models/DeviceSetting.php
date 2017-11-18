<?php

class DeviceSetting extends DB\SQL\Mapper {
	public function __construct(DB\SQL $db) {
		$this->db = $db;
		parent::__construct($db, 'v_device_profile_settings');
	}

        public function getByProfileId($array) {
		$this->load(array('device_profiles_iddevice_profiles=? AND setting_categorie_name=?', array(1=>$array['iddevice_profile'], 2=>$array['categorie'])));
		return $this->query;
	}

	public function getSettingByProfileIdCitrix($array) {
		$this->load(array('device_profiles_iddevice_profiles=? AND setting_categorie_name=? AND setting_name=?', array(1=>$array['iddevice_profile'], 2=>$array['categorie'], 3=>$array['setting_name_alt'])));
		return $this->query;
	}

	public function getNumberOfRows($array) {
		return $this->count(array('device_profiles_iddevice_profiles=? AND setting_categorie_name=?', array(1=>$array['iddevice_profile'], 2=>$array['categorie'])));
		//return $this->query;
	}

	public function edit($array) {
		$result = $this->db->exec('call sp_insert_device_profile_settings(@out,?,?,?,?,?)', array(1=>$array['iddevice_profile'], 2=>$array['categorie'], 3=>$array['setting_name'], 4=>$array['value'], 5=>$array['session_user']));

		return $result;
	}

	public function delete($array) {
		$result = $this->db->exec('call sp_delete_device_profile_settings(@out,?,?,?,?)', array(1=>$array['iddevice_profile'], 2=>$array['categorie'], 3=>$array['setting_name_alt'], 4=>$array['session_user']));

		return $result;
	}

	public function deleteById($id) {
		$result = $this->db->exec('DELETE FROM device_profile_settings WHERE iddevice_profile_settings = ?', $id);
		return $result;
	}

}
