<?php

class MainController extends Controller {

	function beforeroute() {
	
		// we check if user is logged in
		if($this->f3->get('SESSION.user') == null) {
			$this->f3->reroute('/login');
			exit;
		}
	
	}

	function dashboard() {
		$this->f3->set('page_head', 'Dashboard');
		$this->f3->set('view', 'dashboard.htm');
	}
}
