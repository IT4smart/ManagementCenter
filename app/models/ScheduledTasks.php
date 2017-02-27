<?php

class ScheduledTasks extends DB\SQL\Mapper {
	public function __construct(DB\SQL $db) {
		$this->db = $db;
		parent::__construct($db, 'v_scheduled_tasks');
	}
        
        public function add($data) {
            $result = $this->db->exec('call sp_insert_scheduled_tasks(@out, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', array(1 => $data['task_name'], 2 => $data['description'], 3 => $data['state'], 4 => $data['startdate'], 5 => $data['enddate'], 6 => $data['minute'], 7 => $data['hour'], 8 => $data['day_of_month'], 9 => $data['month'], 10 => $data['weekday'], 11 => $data['command'], 12 => $data['device_groups'], 13 => $data['user']));
            return $result;
        }
        
        public function all() {
            $this->load();
            return $this->query;
        }
            
        public function byState($state) {
            $this->load(array('state=?', $state));
            return $this->query;
        }    
        
}