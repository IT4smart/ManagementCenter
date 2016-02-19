<?php

class UserController extends Controller {
	/*function beforeroute() {
		if($this->f3->get('SESSION.user') == null) {
			$this->f3->reroute('/login');
		}
	}*/

	function index() {
		$user = new User($this->db);
        	$usergroup = new UserGroup($this->db);
		$this->f3->set('users', $user->all());
        	$this->f3->set('usergroups', $usergroup->all());
        	$this->f3->set('page_head', $this->f3->get('page_head_user_overview'));
		$this->f3->set('view', 'user/list.htm');

	}

    function create() {
        if($this->f3->exists('POST.create')) {

	    $array['username'] = $this->f3->get('POST.username');
            $array['password'] = $this->f3->get('POST.password');
	    $array['email'] = $this->f3->get('POST.email');
	    $array['usergroup'] = $this->f3->get('POST.usergroup');
	    $array['session_user'] = $this->f3->get('SESSION.user');
            $password2 = $this->f3->get('POST.password2');


	    // check if passwords are equal
            if($array['password'] == $password2) {
                $user = new User($this->db);
		
		

                $result = $user->add($array);


		if($result['result'] == 1) {
	                $this->f3->reroute('/user/success/New user created');
		} else {
			$this->f3->reroute('/user/failed/User couldn\'t added');
		}
            } else {
                $this->f3->reroute('/user/failed/Passwords are not identically');
            }
        } else {

            $usergroup = new UserGroup($this->db);
            $this->f3->set('page_head', 'Create User');
            $this->f3->set('usergroups', $usergroup->all());
            $this->f3->set('view', 'user/create.htm');
        }
    }

   function update() {
	$user = new User($this->db);
	if($this->f3->exists('POST.update')) {

		$user->edit($array);

		if($result['result'] == 1) {
	                $this->f3->reroute('/user/success/user updated');
		} else {
			$this->f3->reroute('/user/failed/User couldn\'t updated');
		}
	} else {
	    $usergroup = new UserGroup($this->db);
	    $this->f3->set('page_head', 'Update User');
	    $this->f3->set('users', $user->getById($this->f3->get('PARAMS.id')));
	    $this->f3->set('usergroups', $usergroup->all());
	    $this->f3->set('view', 'user/edit.htm');
	}

   }
}
