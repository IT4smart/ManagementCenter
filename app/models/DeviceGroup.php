<?php

class DeviceGroup extends DB\SQL\Mapper {
	public function __construct(DB\SQL $db) {
		$this->db = $db;
		parent::__construct($db, 'v_device_groups');
	}

	public function all() {
		$this->load();
		return $this->query;
	}

	public function add($array) {
		$result = $this->db->exec('call sp_insert_device_group(@out,?,?,?,?)', array(1=>$array['groupname'], 2=>$array['description'], 3=>$array['state'], 4=>$array['session_user']));
		return $result;
	}

	public function getById($id) {
		$this->load(array('iddevice_groups=?', $id));
		return $this->query;	
	}

	public function edit($array) {
		$result = $this->db->exec('call sp_update_device_group(@out,?,?,?,?,?)', array(1=>$array['groupid'], 2=>$array['groupname'], 3=>$array['description'], 4=>$array['state'], 5=>$array['session_user']));
		return $result;
	}
}
