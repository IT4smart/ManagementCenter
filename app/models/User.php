<?php

class User extends DB\SQL\Mapper {
	public function __construct(DB\SQL $db) {
		$this->db = $db;
		parent::__construct($db, 'v_users');
	}

	public function all() {
		$this->load();
		return $this->query;
	}

	public function getById($id) {
		$this->load(array('idusers=?', $id));
		return $this->query;
	}

	public function getByName($name) {
		$this->load(array('username=?', $name));
		return $this->query;
	}

	public function add($array) {
		// hash password
		$password = password_hash($array['password'], PASSWORD_DEFAULT);

		$result = $this->db->exec('call sp_insert_user(@out,?,?,?,?,?,?)', array(1=>$array['usergroup'], 2=>$array['username'], 3=>$password, 4=>$array['email'], 5=>1, 6=>$array['session_user']));

		return $result;
	}

        public function editpw($array) {
		$result = $this->db->exec('call sp_update_user_password(@out,?,?,?)', array(1=>$array['user_id'], 2=>$array['password_save'], 3=>$array['session_user']));
		return $result;
	}

	public function editemail($array) {
		$result = $this->db->exec('call sp_update_user_email(@out,?,?,?)', array(1=>$array['user_id'], 2=>$array['email'], 3=>$array['session_user']));
		return $result;
	}

	public function editgroup($array) {
		$result = $this->db->exec('call sp_update_user_usergroup(@out,?,?,?)', array(1=>$array['user_id'], 2=>$array['usergroup'], 3=>$array['session_user']));
		return $result;
	}

	public function delete($id) {
		// start a transaction
		$this->db->begin();
		$result = $this->db->exec("DELETE FROM users WHERE idusers = ?", $id);
		if($result != 0) {
			$this->db->commit();
			$return_code = true;
		} else {
			$this->db-rollback();
			$return_code = false;
		}	

		return $return_code;

	}
}
