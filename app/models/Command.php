<?php

class Command extends DB\SQL\Mapper {
	public function __construct(DB\SQL $db) {
		$this->db = $db;
		parent::__construct($db, 'commands');
	}
        
        public function getByName($name) {
            // get a job
            $this->load(array('command_name=?', $name));
                        
            // return result
            return $this->query;
        }
        
        public function getByInterval($interval) {
            $this->load(array('`interval`=?', $interval));
            return $this->query;
        }
        
        public function getByScheduledTasks($task) {
            $this->load(array('`scheduled_task`=?', $task));
            return $this->query;
        }
        
}