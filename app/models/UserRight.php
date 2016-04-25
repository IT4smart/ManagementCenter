<?php

class UserRight extends DB\SQL\Mapper {
    public function __construct(DB\SQL $db) {
		parent::__construct($db, 'v_user_rights_to_usergroups');
	}

	public function all() {
		$this->load();
		return $this->query;
	}

	public function allUserrights() {
		return $this->db->exec("SELECT * FROM user_rights");
	}

	public function getUserrightsByGroup($group) {
		return $this->db->exec("SELECT * FROM user_rights WHERE user_right_group = ?", $group); 
	}
}
