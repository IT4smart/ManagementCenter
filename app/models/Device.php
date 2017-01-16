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
		$result['result'] = $this->db->exec('call sp_insert_device(@out,?,?,?,?,?,?,?,?)', array(1=>$array['devicename'], 2=>$array['mac'], 3=>$array['serialnumber'], 4=>$array['note'], 5=>$array['devicetype'], 6=>$array['devicegroup'], 7=>$array['photo'], 8=>$array['session_user']));
		$result['out'] = $this->db->exec('SELECT @out');


		return $result;	
	}

	public function byStatus($filter) {
		$this->load(array('state=?',$filter));
        	return $this->query;
	}

	public function getByName($devicename) {
		$this->load(array('device_name=?', $devicename));
		return $this->query;
	}

	public function getDeviceLog($devicename) {
		$result = $this->db->exec('call sp_show_logs(?,?)', array(1=>$devicename['device_name'], 2=>$devicename['lang']));
		return $result;
	}
        
        public function getByMac($mac) {
            $this->load(array('mac_address=?', $mac));
            return $this->query;
        }
        
        public function overviewDeviceState() {
            $result = $this->db->exec('select * from v_dashboard_device_state');
            return $result;
        }
        
        /**
         * 
         * @param type $id
         * @param type $state
         * @param type $user
         */
        public function setDeviceState($id, $state, $user) {
           $result = $this->db->exec('call sp_update_device_state(@out, ?, ?, ?)', array(1=>$id, 2=>$state, 3=>$user));
           return $result;
        }
}