<?php

class MainController extends Controller {
    	function afterroute() {
            echo Template::instance()->render('layout.htm');
	}
    
	function beforeroute() {
	
		// we check if user is logged in
		if($this->f3->get('SESSION.user') == null) {
			$this->f3->reroute('/login');
			exit;
		}
	
	}

	function dashboard() {
                $device_pdata = new DevicePerformanceData($this->db);
                $device_pdata->cnt_value = 'COUNT(value)';
                
                $device = new Device($this->db);
                $device->cnt_state = 'COUNT(state)';

                $this->f3->set('devices_pdata', $device_pdata->overviewDeviceState());
                $this->f3->set('devices', $device->overviewDeviceState());
		$this->f3->set('page_head', 'Dashboard');
		$this->f3->set('view', 'dashboard.htm');
	}
}
