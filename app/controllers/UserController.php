<?php

class UserController extends Controller {
	function beforeroute() {
		// we check if user is logged in
		if($this->f3->get('SESSION.user') == null) {
			$this->f3->reroute('/');
			exit;
		}
	}
    	function afterroute() {
            echo Template::instance()->render('layout.htm');
	}
    
	function index() {
		$user = new User($this->db);
        	$usergroup = new UserGroup($this->db);
		$this->f3->set('users', $user->all());
        	$this->f3->set('usergroups', $usergroup->all());
		$this->f3->set('message', $this->f3->get('PARAMS.message'));
		$this->f3->set('message_warning', $this->f3->get('PARAMS.message_warning'));
		$this->f3->set('message_failed', $this->f3->get('PARAMS.message_failed'));
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

		// debugging
		echo "Result: ".$result;

		if($result == 1) {
	                $this->f3->reroute('/user/success/'.$this->f3-get('reroute_user_success_create'));
		} else {
			$this->f3->reroute('/user/failed/'.$this->f3->get('reroute_user_failed_create'));
		}
            } else {
                $this->f3->reroute('/user/failed/'.$this->f3->get('reroute_user_password_false'));
            }
        } else {

            $usergroup = new UserGroup($this->db);
            $this->f3->set('page_head', $this->f3->get('page_head_create_user'));
            $this->f3->set('usergroups', $usergroup->all());
            $this->f3->set('view', 'user/create.htm');
        }
    }

   function detail() {
	$user = new User($this->db);
	$usergroup = new UserGroup($this->db);

	$this->f3->set('page_head', $this->f3->get('page_head_update_user'));
	$this->f3->set('users', $user->getById($this->f3->get('PARAMS.id')));
	$this->f3->set('usergroups', $usergroup->all());
	$this->f3->set('view', 'user/edit.htm');
   }

   function updatemail() {
	$array['email'] = $this->f3->get('POST.email');
	$array['user_id'] = $this->f3->get('POST.user_id');
	$array['session_user'] = $this->f3->get('SESSION.user');

	if($this->f3->exists('POST.update')) {
		$user = new User($this->db);

		$result = $user->editemail($array);
		
		echo "Result: ".$result;

		if($result == 1) {
			$this->f3->reroute('/user/success/'.$this->f3->get('reroute_user_success_email'));
		} else {
			$this->f3->reroute('/user/failed/'.$this->f3->get('reroute_user_failed_email'));
		}
	} 
   }

   function updatepw() {
	// get all information from POST
	$array['user_id'] = $this->f3->get('POST.user_id');
	$array['password_old'] = $this->f3->get('POST.password_old');
	$array['password_new'] = $this->f3->get('POST.password_new');
	$array['password_new2'] = $this->f3->get('POST.password_new2');
	$array['session_user'] = $this->f3->get('SESSION.user');

	if($this->f3->exists('POST.update')) {
		$user = new User($this->db);

		// check if user typed old password correctly
		$old_user_data = $user->getById($array['user_id']);
		$old_pw = password_hash($old_user_data[0]['password'], PASSWORD_DEFAULT);
		$new_pw = password_hash($array['password_new'], PASSWORD_DEFAULT);

		// check if password from database and the one from user is the same.
		// also we have to check if it's different from the new one.
		if(($old_pw == $array['password_old']) && ($new_pw !== $old_pw)) {
			// now it can be saved.
			$array['password_save'] = $new_pw;
			$result = $user->editpw($array);

		} else {
			$result = 2;
		}

		if($result == 1) {
	                $this->f3->reroute('/user/success/'.$this->f3->get('reroute_user_success_password'));
		} elseif($result == 2) {
			$this->f3->reroute('/user/failed/'.$this->f3->get('reroute_user_old_password'));		
		} else {
			$this->f3->reroute('/user/failed/'.$this->f3->get('reroute_user_failed_password'));
		}
	}

   }

   /**
    * Update usergroup
    */
   function updategroup() {
	$array['usergroup'] = $this->f3->get('POST.usergroup');
	$array['user_id'] = $this->f3->get('POST.user_id');
	$array['session_user'] = $this->f3->get('SESSION.user');

	if($this->f3->exists('POST.update')) {
		$user = new User($this->db);

		$result = $user->editgroup($array);

		if($result == 1) {
			$this->f3->reroute('/user/success/'.$this->f3->get('reroute_usergroup_update_success'));
		} else {
			$this->f3->reroute('/user/failed/'.$this->f3->get('reroute_usergroup_update_failed'));
		}
	}
   }

   function delete() {
	$user = new User($this->db);

	$result = $user->delete($this->f3->get('PARAMS.id'));

	if($result == true) {
		$this->f3->reroute('/user/succcess/'.$this->f3->get('reroute_user_success_delete'));
	} else {
		$this->f3->reroute('/user/failed/'.$this->f3->get('reroute_user_failed_delete'));
	}
   }

   /**
    * Create a usergroup
    */
   function usergroup_create() {
	$array['group_name'] = $this->f3->get('POST.group_name');
	$array['description'] = $this->f3->get('POST.description');
	$array['session_user'] = $this->f3->get('SESSION.user');

	if($this->f3->exists('POST.create')) {
		$usergroup = new UserGroup($this->db);

		$result = $usergroup->add($array);

		if($result == 1) {
			$this->f3->reroute('/user/success/'.$this->f3->get('reroute_usergroup_success'));
		} else {
			$this->f3->reroute('/user/failed/'.$this->f3->get('reroute_usergroup_failed'));
		}
	} else {
		$this->f3->set('page_head', $this->f3->get('page_head_create_usergroup'));
		$this->f3->set('view', 'usergroup/create.htm');
	}
   }

   /**
    * Filter list of user's by usergroup
    */
   function byUsergroup() {
	$user = new User($this->db);
	$usergroup = new UserGroup($this->db);

        $this->f3->set('page_head', $this->f3->get('page_head_user_overview'));
        $this->f3->set('users', $user->getByUsergroupId($this->f3->get('PARAMS.id')));
	$this->f3->set('usergroups', $usergroup->all());
        $this->f3->set('view', 'user/list.htm');
   }

   /**
    * Show details of a specific usergroup
    */
   function usergroup() {
	$usergroup = new UserGroup($this->db);
	$userright = new UserRight($this->db);
	$this->f3->set('page_head', $this->f3->get('page_head_usergroup_detail'));
	$this->f3->set('usergroups', $usergroup->getById($this->f3->get('PARAMS.id')));
	$this->f3->set('userright_device', $userright->getUserrightsByGroup("Device"));
	$this->f3->set('userright_profile', $userright->getUserrightsByGroup("Profile"));
	$this->f3->set('userright_profilegroup', $userright->getUserrightsByGroup("Profilegroup"));
	$this->f3->set('userright_user', $userright->getUserrightsByGroup("User"));
	$this->f3->set('userright_usergroup', $userright->getUserrightsByGroup("Usergroup"));
	$this->f3->set('userright_report', $userright->getUserrightsByGroup("Report"));
	$this->f3->set('userright_right', $userright->getUserrightsByGroup("Right"));
	$this->f3->set('view', 'usergroup/detail.htm');
   }

   /**
    * Update userrights
    */
   function userright_update() {
	if($this->f3->exists('POST.update')) {

	}
   }
}
