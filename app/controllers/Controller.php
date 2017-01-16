<?php

class Controller {
	protected $f3;
	protected $db;

	function beforeroute() {
	/****************************
	 * ToDo:
	 * - add check if a user is logged in.
	 ****************************/
		if(($this->f3->get('SESSION.user') == null) && (!$this->f3->get('PATH'))) {
			$this->f3->reroute('/');
			exit;
		}
	}

	function afterroute() {
		//echo Template::instance()->render('layout.htm');
	}

	function __construct() {
		$f3 = Base::instance();
		$this->f3 = $f3;

		$db = new DB\SQL(
			$f3->get('db'),
			$f3->get('dbusername'),
			$f3->get('dbpassword'),
			array( \PDO::ATTR_ERRMODE => \PDO::ERRMODE_EXCEPTION)
		);
	
		$this->db = $db;
	}
}
