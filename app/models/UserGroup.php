<?php

class UserGroup extends DB\SQL\Mapper {
    public function __construct(DB\SQL $db) {
		parent::__construct($db, 'usergroups');
	}

	public function all() {
		$this->load();
		return $this->query;
	}

	public function getById($id) {
		$this->load(array('idusergroups=?', $id));
		return $this->query;
	}

	public function add($array) {
		$result = $this->db->exec('call sp_insert_usergroup(@out,?,?,?)', array(1=>$array['group_name'], 2=>$array['description'], 3=>$array['session_user']));
		return $result;		
	}

}
