<?php

class UserGroup extends DB\SQL\Mapper {
    public function __construct(DB\SQL $db) {
		parent::__construct($db, 'usergroups');
	}

	public function all() {
		$this->load();
		return $this->query;
	}


}
