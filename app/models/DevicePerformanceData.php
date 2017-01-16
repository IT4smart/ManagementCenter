<?php

class DevicePerformanceData extends DB\SQL\Mapper {
	public function __construct(DB\SQL $db) {
		$this->db = $db;
		parent::__construct($db, 'v_device_performance_data');
	}

	public function all() {
		$this->load();
		return $this->query;
	}

	public function getByDeviceId($id) {
		$this->load(array('device_iddevice=?', $id));
		return $this->query;
	}
        
        public function overviewDeviceState() {
            $result = $this->db->exec('select * from v_dashboard_device_performance_data_state');
            return $result;
        }
}

