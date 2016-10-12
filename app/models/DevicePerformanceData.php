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
            $this->load(array('name=?', 'state'), array('group' => 'value'));
            return $this->query;
        }
}

