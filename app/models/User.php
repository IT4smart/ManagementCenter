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

		$result['result'] = $this->db->exec('call sp_insert_user(@out,?,?,?,?,?,?)', array(1=>$array['usergroup'], 2=>$array['username'], 3=>$password, 4=>$array['email'], 5=>1, 6=>$array['session_user']));
		$result['out'] = $this->db->exec('SELECT @out');


		return $result;
	}

	public function edit($id) {
		$this->load(array('idusers=?', $id));
		$this->copyFrom('POST');
		$this->update();
	}

	public function delete($id) {
		$this->load(array('idusers=?', $id));
		$this->erase();
	}
}
