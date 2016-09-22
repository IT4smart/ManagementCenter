<?php

class AuthController extends Controller {
    	function afterroute() {
            echo Template::instance()->render('layout.htm');
	}
    
	function render() {
		$this->f3->set('page_head', $this->f3->get('page_head_login'));
		$this->f3->set('message', $this->f3->get('PARAMS.message'));
		$this->f3->set('message_failed', $this->f3->get('PARAMS.message_failed'));
		$this->f3->set('view', 'login.htm');
	}


	function authenticate() {
		$username = $this->f3->get('POST.username');
		$password = $this->f3->get('POST.password');

		$user = new User($this->db);
		$user->getByName($username);

		
		if($user->dry()) {
			$this->f3->reroute('/failed/Empty fields!');
		}

		if(password_verify($password, $user->password)) {
			$this->f3->set('SESSION.user', $user->username);
			$this->f3->reroute('/dashboard');
		} else {
			$this->f3->reroute('/failed/Failed to login! Please try again.');
		}
	}

    	function logout() {
        	$this->f3->clear('SESSION');
        	$this->f3->reroute('/Successfully logged out');
    	}
}
