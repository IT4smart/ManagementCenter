<?php

/**
 * @file   GroupController.php
 * @brief  Controller to handle device profiles.
 * @date   04.January 2016
 * @author Raphael Lekies <raphael.lekies@it4s.eu>
 */


/**
 * @class ProfileController
 * @brief This is a class to demonstrate how to use Doxygen in this project.
 * @todo Replace all success and failed messages with translations. Also implement for display them.
 */

class GroupController extends Controller {
	function index() {
		$device_group = new DeviceGroup($this->db);
		$this->f3->set('device_groups', $device_group->all());
		$this->f3->set('message', $this->f3->get('PARAMS.message'));
		$this->f3->set('message_warning', $this->f3->get('PARAMS.message_warning'));
		$this->f3->set('message_failed', $this->f3->get('PARAMS.message_failed'));
        	$this->f3->set('page_head', $this->f3->get('page_head_device_group'));
		$this->f3->set('view', 'group/list.htm');
	}

	function create() {
        	if($this->f3->exists('POST.create')) {
			$array['groupname'] = $this->f3->get('POST.groupname');
			$array['description'] = $this->f3->get('POST.groupdescription');
			$array['state'] = $this->f3->get('POST.optionsRadios');
			$array['session_user'] = $this->f3->get('SESSION.user');

	    		// add new device profile
            		$device_group = new DeviceGroup($this->db);
	    		$result = $device_group->add($array);

			
			if($result['result'] == 1) {
			        $this->f3->reroute('/group/success/'.$this->f3->get('reroute_group_success'));
	    		} else {
				$this->f3->reroute('/group/failed/'.$this->f3->get('reroute_group_failed'));
	    		}

        	} else {
	            $this->f3->set('page_head', $this->f3->get('page_head_create_group'));
	            $this->f3->set('view', 'group/create.htm');
        	}
	}

	function update() {
		if($this->f3->exists('POST.update')) {
			$array['groupid'] = $this->f3->get('POST.group_id');
			$array['groupname'] = $this->f3->get('POST.groupname');
			$array['description'] = $this->f3->get('POST.groupdescription');
			$array['state'] = $this->f3->get('POST.optionsRadios');
			$array['session_user'] = $this->f3->get('SESSION.user');

			$device_group = new DeviceGroup($this->db);

			$result = $device_group->edit($array);

			if($result == 1) {
				$this->f3->reroute('/group/success/'.$this->f3->get('reroute_group_update_success'));
			} else {
				$this->f3->reroute('/group/failed/'.$this->f3->get('reroute_group_update_failed'));
			}


		} else {
			$device_group = new DeviceGroup($this->db);
			
			$this->f3->set('page_head', $this->f3->get('page_head_update_group'));
			$this->f3->set('device_groups', $device_group->getById($this->f3->get('PARAMS.id')));			
			$this->f3->set('view', 'group/update.htm');
		}
	

	}

	function clients() {
		if($this->f3->get('POST.update')) {
			// declare
			$device_assignment = new DeviceAssignment($this->db);
			$selected_arr = array();
			$array['group_id'] = $this->f3->get('POST.group_id');
			$selected_arr = $this->f3->get('POST.device');	
			$array['session_user'] = $this->f3->get('SESSION.user');		

			//var_dump($this->f3->get('POST'));

			if($this->f3->get('POST.device') ==! null) {
				// at first we get all assigned devices to the specific group.
				// if we can't find the value in selected array. delete it.
				$device_assigned = $device_assignment->getByGroupId($array['group_id']);
				//var_dump($device_assigned[0]);
				//echo 'Device: '.$device_assigned[0]['iddevice'].'<br>';				

				// search device in selected array
				$deleted = 0;
				$result_delete = 0;
				for ($i = 0; $i < count($device_assigned); $i++) {
					$delete = array_search($device_assigned[$i]['iddevice'], $selected_arr);

					// delete the device. it's no more a part of this group
					if($delete === false) {
						$array['delete'] = $device_assigned[$i]['iddevice'];
						$result_delete += $device_assignment->delete($array);
						$deleted++;
					}
				}

				// we have to hack it here a little bit.
				// we can't find any result in $device_assigned with the function array_search
				// so now we place all id's that are already assigned in an extra array.
				$devices_tmp = array();

				for($k = 0; $k < count($device_assigned); $k++) {
					$devices_tmp[$k] = $device_assigned[$k]['iddevice'];
				}


				// all clients added to group wil be now added to database
				// after hacking the original array $device_assigned. Now it must be easier for array_search()
				$added = 0;
				$result_add = 0;
				foreach($selected_arr as $selected) {
					//echo $device_assigned[1]['iddevice']."<br/>";
					//$add = array_search($selected, $devices_tmp);
					$add = in_array($selected, $devices_tmp);
					echo 'Device to add: '.$selected.'<br>';
					echo 'Device found in array: '.$add.'<br>';
					//var_dump($device_assigned);

					// add device to group
					if($add == false) {
						$array['add'] = $selected;
						var_dump($array);
						$result_add += $device_assignment->add($array);
						$added++;
					}
				}

				if(($result_add == $added) && ($result_delete == $deleted) && (($result_add > 0 ) || ($resulte_delete > 0))) {
					echo "Result add: ".$result_add."<br>";
					echo "Added: ".$added."<br>";


					//$this->f3->reroute('/group/success/'.$this->f3->get('reroute_clients_success'));
				} else {
					//$this->f3->reroute('/group/failed/'.$this->f3->get('reroute_clients_failed'));
				}

			} else {
				//$this->f3->reroute('/group/warning/'.$this->f3->get('reroute_clients_warning'));
			}
			
		} else {
			$device = new Device($this->db);
			$device_assignment = new DeviceAssignment($this->db);		

			$this->f3->set('page_head', $this->f3->get('page_head_update_group_clients'));
			$this->f3->set('devices', $device->all());
			$this->f3->set('device_assignments', $device_assignment->getByGroupId($this->f3->get('PARAMS.id')));
			$this->f3->set('view', 'group/clients.htm');
		}
	}
}
