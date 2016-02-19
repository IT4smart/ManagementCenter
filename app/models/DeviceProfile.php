<?php

class DeviceProfile extends DB\SQL\Mapper {
	public function __construct(DB\SQL $db) {
		$this->db = $db;
		parent::__construct($db, 'v_device_profiles');
	}

	public function all() {
		$this->load();
		return $this->query;
	}

	public function getProfilesSummaryByDeviceName($devicename) {
		return $this->db->exec('SELECT * FROM v_device_summary_device_profiles where device_name=?', $devicename);
	}

	public function add($array) {
		$result['result'] = $this->db->exec('call sp_insert_device_profiles(@out,?,?,?,?)', array(1=>$array['profilename'], 2=>$array['description'], 3=>$array['state'], 4=>$array['session_user']));
		$result['out'] = $this->db->exec('SELECT @out');

		return $result;

	}

	public function edit($array) {
		$result['result'] = $this->db->exec('call sp_update_device_profiles(@out,?,?,?,?,?)', array(1=>$array['iddevice_profile'], 2=>$array['profilename'], 3=>$array['description'], 4=>$array['state'], 5=>$array['session_user']));
		$result['out'] = $this->db->exec('SELECT @out');

		return $result;
	}

	public function getById($id) {
        	$this->load(array('iddevice_profiles=?',$id));	
		return $this->query;	
	}
}
