<?php

class DeviceType extends DB\SQL\Mapper {
	public function __construct(DB\SQL $db) {
		$this->db = $db;
		parent::__construct($db, 'device_types');
	}

	public function all() {
		$this->load();
		return $this->query;
	}

}
