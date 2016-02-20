<?php

class DeviceAssignment extends DB\SQL\Mapper {
	public function __construct(DB\SQL $db) {
		$this->db = $db;
		parent::__construct($db, 'v_device_to_device_group');
	}
	
	public function all() {
		$this->load();
		return $this->query;
	}

	public function getByGroupId($group_id) {
		$this->load(array('iddevice_groups=?', $group_id));
		return $this->query;	
	}

	public function getByDeviceName($device_name) {
		$this->load(array('device_name=?', $device_name));
		return $this->query;
	}

	public function delete($array) {
		$result = $this->db->exec('call sp_delete_device_to_device_group(@out,?,?,?)', array(1=>$array['delete'], 2=>$array['group_id'], 3=>$array['session_user']));
		return $result;
	}

	public function add($array) {
		$result = $this->db->exec('call sp_insert_device_to_device_group(@out,?,?,?)', array(1=>$array['add'], 2=>$array['group_id'], 3=>$array['session_user']));
		return $result;
	}
}
