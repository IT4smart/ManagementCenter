<?php

class Device extends DB\SQL\Mapper {
	public function __construct(DB\SQL $db) {
		$this->db = $db;
		parent::__construct($db, 'v_devices');
	}

	public function all() {
		$this->load();
		return $this->query;
	}

        public function add($array) {
		$result['result'] = $this->db->exec('call sp_insert_device(@out,?,?,?,?,?,?,?,?,?)', array(1=>$array['devicename'], 2=>$array['mac'], 3=>$array['ip'], 4=>$array['serialnumber'], 5=>$array['note'], 6=>$array['devicetype'], 7=>$array['devicegroup'], 8=>$array['photo'], 9=>$array['session_user']));
		$result['out'] = $this->db->exec('SELECT @out');


		return $result;	
	}

	public function byStatus($filter) {
		$this->load(array('state=?',$filter));
        	$this->copyTo('POST');
	}

	public function getByName($devicename) {
		$this->load(array('device_name=?', $devicename));
		return $this->query;
	}

	public function getDeviceLog($devicename) {
		$result = $this->db->exec('call sp_show_logs(?,?)', array(1=>$devicename['device_name'], 2=>$devicename['lang']));
		return $result;
	}
}

