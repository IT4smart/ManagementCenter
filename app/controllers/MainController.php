<?php

class MainController extends Controller {
    	function afterroute() {
            echo Template::instance()->render('layout.htm');
	}
    
	function beforeroute() {
	
		// we check if user is logged in
		if($this->f3->get('SESSION.user') == null) {
			$this->f3->reroute('/');
			exit;
		}
	
	}

	function dashboard() {
                $device_pdata = new DevicePerformanceData($this->db);
                
                $device = new Device($this->db);

                
                $this->f3->set('devices_pdata', $device_pdata->overviewDeviceState());
                $this->f3->set('devices', $device->overviewDeviceState());
		$this->f3->set('page_head', 'Dashboard');
		$this->f3->set('view', 'dashboard.htm');
	}
}
