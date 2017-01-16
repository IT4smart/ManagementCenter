<?php

class DeviceProfileAssignment extends DB\SQL\Mapper {
	public function __construct(DB\SQL $db) {
		$this->db = $db;
		parent::__construct($db, 'v_profile_to_device_group');
	}
	
	public function all() {
		$this->load();
		return $this->query;
	}

	public function getByGroupId($profile_id) {
		$this->load(array('iddevice_groups=?', $profile_id));
		return $this->query;	
	}

	public function add($array) {
		$result = $this->db->exec('call sp_insert_device_profiles_to_device_groups(@out,?,?,?,?)', array(1=>$array['add'], 2=>$array['group_id'], 3=>$array['order'], 4=>$array['session_user']));
		return $result;
	}

	public function delete($array) {
		$result = $this->db->exec('call sp_delete_device_profiles_to_device_groups(@out,?,?,?)', array(1=>$array['delete'], 2=>$array['group_id'], 3=>$array['session_user']));
		return $result;
	}
}
