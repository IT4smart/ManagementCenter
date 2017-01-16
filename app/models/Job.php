<?php

class Job extends DB\SQL\Mapper {
	public function __construct(DB\SQL $db) {
		$this->db = $db;
		parent::__construct($db, 'v_command_jobs');
	}
        
        public function getJobByMac($mac) {
            // get a job
            $this->load(array('mac_address=? and (state is null or state = ?) and timestamp <= now()', array(1 => $mac, 2 => 'failed')), array('order' => 'timestamp', 'limit' => 1));
                        
            // return result
            return $this->query;
        }
        
        // set state of the currrent job
        public function setJobState($id, $state) {
            $result = $this->db->exec('call sp_update_command_jobs(@out, ?, ?, ?, ?)', array(1 => 'agent', 2 => $id, 3 => $state, 4 => ''));
            return $result;
        }
        
        public function setDeviceState($state, $device_id, $id) {
            $result = $this->db->exec('call sp_update_device_performance_data(@out,?, ?, ?, ?, ?)', array(1=>$device_id, 2=>'state', 3=>$state, 4=>$id, 5=>'agent'));
            return $result;
        }
        
        public function addDeviceData($name, $value, $device_id, $id) {
            $result = $this->db->exec('call sp_update_device_performance_data(@out, ?, ?, ?, ?, ?)', array(1=>$device_id, 2=>$name, 3=>$value, 4=>$id, 5=>'agent'));
            return $result;
        }
        
        public function setDeviceUptime($time, $device_id, $id) {
            $result = $this->db->exec('call sp_update_device_uptime(@out, ?, ?, ?, ?, ?)', array(1=>$device_id, 2=>'uptime', 3=>$time, 4=>$id, 5=>'agent'));
            return $result;
        }

        /**
         * 
         * @param type $command_id
         * @param type $device_id
         * @param type $interval
         * @todo insert real user which is responsible for the new job
         */
        public function addJob($command_id, $device_id, $interval, $payload) {
            $result = $this->db->exec('call sp_insert_command_jobs(@out, ?, ?, ?, ?, ?)', array(1=>$command_id, 2=>$device_id, 3=>$interval, 4=>$payload, 5=>'web'));
            return $result;
        }
        
        public function addPackageData($package_name, $version, $device_id) {
            $result = $this->db->exec('call sp_insert_device_package_data(@out, ?, ?, ?, ?)', array(1=>$package_name, 2=>$version, 3=>$device_id, 4=>'agent'));
            return $result;
        }
        
        /**
         * 
         * @param type $mac
         * @param type $hostname
         * @return type
         */
        public function addDeviceRegisterJob($mac, $hostname) {
            $result = $this->db->exec('call sp_insert_device_to_register(@out, ?, ?, ?)', array(1=>$mac, 2=>$hostname, 3=>'agent'));
            return $result;
        }
        
        /**
         * Get the current job state of a device which is will be registering.
         * @param type $mac
         */
        public function getRegisterStateByMac($mac) {
            $result = $this->db->exec("SELECT * FROM v_device_registering_jobs where `mac` = ? and `state` not in ('done') limit 1",$mac);
            return $result;
        } 
        
        /**
         * Set state of device registering job
         * @param type $id
         * @param type $state
         */
        public function setRegisterState($id, $state) {
            $result = $this->db->exec('call sp_update_device_registering_job(@out, ?, ?, ?)', array(1=>$id, 2=>$state, 3=>'agent'));
            return $result;
        }
}     
