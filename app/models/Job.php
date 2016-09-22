<?php

class Job extends DB\SQL\Mapper {
	public function __construct(DB\SQL $db) {
		$this->db = $db;
		parent::__construct($db, 'v_command_jobs');
	}
        
        public function getJobByMac($mac) {
            // get a job
            $this->load(array('mac_address=? and (state is null or state = ?)', array(1 => $mac, 2 => 'failed')), array('order' => 'timestamp desc', 'limit' => 1));
                        
            // return result
            return $this->query;
        }
        
        // set state of the currrent job
        public function setJobState($id, $state) {
            $result = $this->db->exec('call sp_update_command_jobs(@out, ?, ?, ?, ?)', array(1 => 'agent', 2 => $id, 3 => $state, 4 => ''));
            return $result;
        }
        
        public function setDeviceState($state, $device_id, $ip, $id) {
            $result = $this->db->exec('call sp_update_device_state(@out,?, ?, ?, ?, ?)', array(1=>$device_id, 2=>$state, 3=>$ip, 4=>$id, 5=>'agent'));
            return $result;
        }
}     
