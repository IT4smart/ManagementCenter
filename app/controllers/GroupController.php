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
    	function afterroute() {
            echo Template::instance()->render('layout.htm');
	}
        
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

			var_dump($this->f3->get('POST'));
			// at first we get all assigned devices to the specific group.
			//echo "Search for group: ".$array['group_id']."<br>";
			$device_assigned = $device_assignment->getByGroupId($array['group_id']);
			//var_dump($device_assigned);

			if(($this->f3->get('POST.device') ==! null) || (count($device_assigned) ==! 0)) {

				echo 'Device: '.$device_assigned[0]['iddevice'].'<br>';				

				// search device in selected array
				// if we can't find it here we have to delete it.
				$deleted = 0;
				$result_delete = 0;
				for ($i = 0; $i < count($device_assigned); $i++) {

					// if no device is selected we have to delete all from the group.
					if(count($selected_arr) === 0) {
						//echo "We have to delete all devices from group!<br>";
						$array['delete'] = $device_assigned[$i]['iddevice'];
						//echo "Device to delete: ".$array['delete']."<br>";
						$result_delete += $device_assignment->delete($array);
						$deleted++;
					} else {
						$delete = array_search($device_assigned[$i]['iddevice'], $selected_arr);
						//echo "Device delete: ".$delete."<br>";

						// delete the device. it's no more a part of this group
						if($delete === false) {
							$array['delete'] = $device_assigned[$i]['iddevice'];
							echo "Device to delete: ".$array['delete']."<br>";
							$result_delete += $device_assignment->delete($array);
							$deleted++;
						}
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
				// only add something if there was something selected.
				if(count($selected_arr) ==! 0) {
					foreach($selected_arr as $selected) {
						//echo $device_assigned[1]['iddevice']."<br/>";
						//$add = array_search($selected, $devices_tmp);
						$add = in_array($selected, $devices_tmp);
						//echo 'Device to add: '.$selected.'<br>';
						//echo 'Device found in array: '.$add.'<br>';
						//var_dump($device_assigned);

						// add device to group
						if($add == false) {
							$array['add'] = $selected;
							var_dump($array);
							$result_add += $device_assignment->add($array);
							$added++;
						}
					}
				}

				if(($result_add == $added) && ($result_delete == $deleted) && (($result_add > 0 ) || ($result_delete > 0))) {
					//echo "Result add: ".$result_add."<br>";
					//echo "Added: ".$added."<br>";
					//echo "Result delete: ".$result_delete."<br>";
					//echo "Deleted: ".$deleted."<br>";


					$this->f3->reroute('/group/success/'.$this->f3->get('reroute_clients_success'));
				} else {
					$this->f3->reroute('/group/failed/'.$this->f3->get('reroute_clients_failed'));
				}

			} else {
				$this->f3->reroute('/group/warning/'.$this->f3->get('reroute_clients_warning'));
			}
			
		} else {
			$device = new Device($this->db);
			$device_assignment = new DeviceAssignment($this->db);		

			$this->f3->set('page_head', $this->f3->get('page_head_update_group_clients'));
			$this->f3->set('devices', $device->byStatus('activated'));
			$this->f3->set('device_assignments', $device_assignment->getByGroupId($this->f3->get('PARAMS.id')));
			$this->f3->set('view', 'group/clients.htm');
		}
	}

	
        /**
         * Handle profiles 
         */
	function profiles() {
		if($this->f3->get('POST.update')) {
			// declare
			$profile_assignment = new DeviceProfileAssignment($this->db);
			$selected_arr = array();
			$array['group_id'] = $this->f3->get('POST.group_id');
			$selected_arr = $this->f3->get('POST.profile');	
			$array['session_user'] = $this->f3->get('SESSION.user');		

			//var_dump($this->f3->get('POST'));
                        //var_dump($selected_arr);
                        //print_r('<br>');
                        
                                                
			// at first we get all assigned profiles to the specific group.
			//echo "Search for group: ".$array['group_id']."<br>";
			$profile_assigned = $profile_assignment->getByGroupId($array['group_id']);
			//var_dump($profile_assigned);
                        //print_r('<br>');
                        
                        //print_r('Count assigned profiles: '.count($profile_assigned).'<br>');
                        

			if(($this->f3->get('POST.profile') ==! null) || (count($profile_assigned) ==! 0)) {

				$result_added = 0;				
                                $result_deleted = 0;
                                $added = 0;
                                $deleted = 0;
                                
                                // count user selected profiles
                                $cnt_selected_profiles = count($selected_arr['id']);
                                //print_r('Count selected profiles: '.$cnt_selected_profiles.'<br>');


                                // At first we check if a user unselected any profile that is assigned.
                                if(count($profile_assigned) > $cnt_selected_profiles) {
                                    // we need to delete some assigned profiles
                                    //print_r('We delete profiles.<br>');
                                    
                                    // Delete all assigned profiles
                                    if($cnt_selected_profiles == 0) {
                                        //print_r('Delete all profiles<br>');
                                        for($i = 0; $i < count($profile_assigned); $i++) {
                                            $array['delete'] = $profile_assigned[$i]['iddevice_profiles'];
                                            $result_deleted += $profile_assignment->delete($array);
                                            $deleted++;
                                        }
                                    }
                                    
                                    // Find all profiles which are unselected
                                    if($cnt_selected_profiles > 0) {
                                        //print_r('We delete only some profiles<br>');
                                        for($i = 0; $i < count($profile_assigned); $i++) {
                                            $delete = array_search($profile_assigned[$i]['iddevice_profiles'], $selected_arr['id']);
                                            
                                            if($delete === false) {
                                                //print_r("Delete profile: ".$profile_assigned[$i]['iddevice_profiles'].'<br>');
                                                $array['delete'] = $profile_assigned[$i]['iddevice_profiles'];
                                                $result_deleted += $profile_assignment->delete($array);
                                                $deleted++;
                                            }
                                        }
                                    }
                                }
                                
                                // we add the selected profiles
                                if($cnt_selected_profiles > count($profile_assigned)) {
                                    // Check which profile is assigned
                                    // Add all selected profiles
                                    if(count($profile_assigned) == 0) {
                                        //print_r('We add those profiles.<br>');
                                        for($i = 0; $i < $cnt_selected_profiles; $i++) {
                                            $array['add'] = $selected_arr['id'][$i];
                                            $array['order'] = $selected_arr['order'][$i];
                                            //var_dump($array);
                                            //print_r('<br>');
                                            $result_added += $profile_assignment->add($array);
                                            $added++;
                                        }
                                    }
                                    
                                    // Add only the selected profiles
                                    if(count($profile_assigned) > 0) {
                                        //print_r('We are add some profiles<br>');
                                        for($i = 0; $i < $cnt_selected_profiles; $i++) {
                                            $add = array_search($selected_arr['id'][$i], array_column($profile_assigned, 'iddevice_profiles'));
                                            
                                            if($add === false) {
                                                //print_r("Profile to add: ".$selected_arr['id'][$i].'<br>');
                                                $array['add'] = $selected_arr['id'][$i];
                                                $array['order'] = $selected_arr['order'][$i];
                                                $result_added += $profile_assignment->add($array);
                                                $added++;
                                            }
                                        }
                                    }
                                }
                                
                                // At least we check if all went right with adding or deleting the profiles from the group.
                                if(($result_added == $added) && ($result_deleted == $deleted) && (($result_added > 0 ) || ($result_deleted > 0))) {
                                    //print_r("Result add: ".$result_added."<br>");
                                    //print_r("Added: ".$added."<br>");
                                    //print_r("Result delete: ".$result_deleted."<br>");
                                    //print_r("Deleted: ".$deleted."<br>");
                                    //print_r('all right :)');


                                    $this->f3->reroute('/group/success/'.$this->f3->get('reroute_profiles_success'));
				} else {
                                    //print_r("Result add: ".$result_added."<br>");
                                    //print_r("Added: ".$added."<br>");
                                    //print_r("Result delete: ".$result_deleted."<br>");
                                    //print_r("Deleted: ".$deleted."<br>");
                                    //print_r("Something went wrong to add or delete some profiles");
					
                                    $this->f3->reroute('/group/failed/'.$this->f3->get('reroute_profiles_failed'));
				}
                                
                                
			} else {
				$this->f3->reroute('/group/warning/'.$this->f3->get('reroute_profiles_warning'));
			}
                        
                         
			
		} else {
			$profile = new DeviceProfile($this->db);
			$profile_assignment = new DeviceProfileAssignment($this->db);			

			$this->f3->set('page_head', $this->f3->get('page_head_update_group_profiles'));
			$this->f3->set('profiles', $profile->all());
			$this->f3->set('profile_assignments', $profile_assignment->getByGroupId($this->f3->get('PARAMS.id')));
			$this->f3->set('view', 'group/profiles.htm');
		}

	}
}
