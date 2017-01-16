<?php

class Reports extends DB\SQL\Mapper {
	public function __construct(DB\SQL $db) {
		$this->db = $db;
		parent::__construct($db, 'v_report_overview_jobs');
                $this->itemsMaxPage = 50;
	}
        
        public function getOverviewJobs() {
            $page = \Pagination::findCurrentPage();
            $this->load(NULL, array('order' => 'timestamp desc'));
            $result = $this->paginate($page-1, $this->itemsMaxPage, NULL, array('order' => 'timestamp desc'));
            // return result
            return $result;
        }        
        
        public function getOverviewJobsByState($state) {
            $page = \Pagination::findCurrentPage();
            if($state == "open") {
                $this->load(array('state is null'), array('order' => 'timestamp desc'));
                $result = $this->paginate($page-1, $this->itemsMaxPage, array('state is null'), array('order' => 'timestamp desc'));
            } else {
                $this->load(array('`state`=?', $state), array('order' => 'timestamp desc'));
                $result = $this->paginate($page-1, $this->itemsMaxPage, array('`state`=?', $state), array('order' => 'timestamp desc'));
            }
                        
            // return result
            return $result;
        }
        
        public function getOverviewJobStates() {
            $result = $this->db->exec('select `state` from v_report_overview_jobs group by `state`;');
            return $result;
        }
}