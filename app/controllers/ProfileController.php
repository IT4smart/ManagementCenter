<?php

/**
 * @file   ProfileController.php
 * @brief  Controller to handle device profiles.
 * @date   04.January 2015
 * @author Raphael Lekies <raphael.lekies@it4s.eu>
 */


/**
 * @class ProfileController
 * @brief This is a class to demonstrate how to use Doxygen in this project.
 * @todo Replace all success and failed messages with translations. Also implement for display them.
 */
class ProfileController extends Controller {
    	function afterroute() {
            echo Template::instance()->render('layout.htm');
	}

	function index() {
		$device_profile = new DeviceProfile($this->db);
		$this->f3->set('device_profiles', $device_profile->all());
		$this->f3->set('message', $this->f3->get('PARAMS.message'));
		$this->f3->set('message_warning', $this->f3->get('PARAMS.message_warning'));
		$this->f3->set('message_failed', $this->f3->get('PARAMS.message_failed'));
        	$this->f3->set('page_head', 'Device Profile Overview');
		$this->f3->set('view', 'profile/list.htm');
	}

	function create() {
        	if($this->f3->exists('POST.create')) {
			$array['profilename'] = $this->f3->get('POST.profilename');
			$array['description'] = $this->f3->get('POST.profiledescription');
			$array['state'] = $this->f3->get('POST.optionsRadios');
			$array['session_user'] = $this->f3->get('SESSION.user');

	    		// add new device profile
            		$device_profile = new DeviceProfile($this->db);
	    		$result = $device_profile->add($array);

			
			if($result['result'] == 1) {
			        $this->f3->reroute('/profile/success/New profile created');
	    		} else {
				$this->f3->reroute('/profile/failed/Profile couldn\'t added');
	    		}

        	} else {
	            $this->f3->set('page_head', 'Create Profile');
	            $this->f3->set('view', 'profile/create.htm');
        	}
	}

   function update() {
	$device_profile = new DeviceProfile($this->db);
	if($this->f3->exists('POST.update')) {
		$array['profilename'] = $this->f3->get('POST.profilename');
		$array['description'] = $this->f3->get('POST.profiledescription');
		$array['state'] = $this->f3->get('POST.optionsRadios');
		$array['iddevice_profile'] = $this->f3->get('POST.profile_id');
		$array['session_user'] = $this->f3->get('SESSION.user');

		$result = $device_profile->edit($array);

		if($result['result'] == 1) {
	                $this->f3->reroute('/profile/success/profile updated');
		} else {
			$this->f3->reroute('/profile/failed/Profile couldn\'t updated');
		}
	} else {
	    $this->f3->set('page_head', $this->f3->get('page_head_update_profile'));
	    $this->f3->set('device_profiles', $device_profile->getById($this->f3->get('PARAMS.id')));
	    $this->f3->set('view', 'profile/update.htm');
	}

   }

   /**
    * @brief	We check if there is any RDP profile setting for the given profile
    * @return	return number of rows we found
    */
   function check_rdp_setting($array) {
	$device_setting = new DeviceSetting($this->db);

	// change categorie
	$array['categorie'] = 'RDP';

	return $device_setting->getNumberOfRows($array);
   }

   /**
    * configure remote sessions
    */
   function profile_session() {
       $device_setting = new DeviceSetting($this->db);
       
       if($this->f3->exists('POST.update')) {
            $array['iddevice_profile'] = $this->f3->get('POST.profile_id');
            $array['categorie'] = $this->f3->get('POST.setting_categorie_name');
            $array['session_user'] = $this->f3->get('SESSION.user');

            // We insert settings for a citrix session
            if($array['categorie'] == "Citrix") {
                // Check if we have rdp settings
                $array['categorie'] = "RDP";
                if($device_setting->getNumberOfRows($array) > 0) {
                    // There are some rdp settings. We delete them.
                    
                }
                
            }
           
       } else {
           $array['iddevice_profile'] = $this->f3->get('PARAMS.id');
           
           // get citrix settings
           $array['categorie'] = 'Citrix';
           $cnt_ctx_setting = $device_setting->getNumberOfRows($array);
           
           // check if citrix settings exists
           if($cnt_ctx_setting > 0) {
            $citrix_settings = $device_setting->getByProfileId($array);
            $this->f3->set('ctx_profile_settings', $citrix_settings);
           }
           
           // get rdp settings
           $array['categorie'] = 'RDP';
           $cnt_rdp_setting = $device_setting->getNumberOfRows($array);
           
           // check if rdp settings exists
           if($cnt_rdp_setting > 0) {
            $rdp_settings = $device_setting->getByProfileId($array);
            $this->f3->set('rdp_profile_settings', $rdp_settings);
           }
           
           $this->f3->set('page_head', $this->f3->get('page_head_session_settings'));
           $this->f3->set('cnt_ctx_setting', $cnt_ctx_setting);
           $this->f3->set('cnt_rdp_setting', $cnt_rdp_setting);
           $this->f3->set('view', 'profile/profile_session.htm');
           
       }
   }

   /**
    * @todo	At file 'profile_ctx.htm' we have to add that input fields can be disabled and enabled if a specific radiobutton clicked.
    */
   function profile_ctx() {
        $device_setting = new DeviceSetting($this->db);
        if($this->f3->exists('POST.update')) {
		$array['iddevice_profile'] = $this->f3->get('POST.profile_id');
		$array['categorie'] = $this->f3->get('POST.setting_categorie_name');
		$array['session_user'] = $this->f3->get('SESSION.user');

		// Before we insert the new setting we have to check if there is a previous one and delete it.
		// Also we have to check if there is no rdp setting
		if($this->check_rdp_setting($array) != 0) {
			$this->f3->reroute('/profile/failed/'.$this->f3->get('reroute_rdp_profile_rdp_failed'));
		}


		if($this->f3->get('POST.optionsRadios') == '1') {
			$array['setting_name'] = 'storefront';
			$array['value'] = $this->f3->get('POST.storefront_url');

			$array['setting_name_alt'] = 'pna';
			$setting = $device_setting->getSettingByProfileIdCitrix($array);

			if($setting[0]->setting_name == "pna") {
                            // now we need to delete it first.
                            $result['deleted'] = $device_setting->delete($array);
			} else {
                            // No citrix settings are currently in the database for this profile
                            // We can add it
                            $result['deleted'] = 1;
                        }
                        

		} else if ($this->f3->get('POST.optionsRadios') == '2') {
			$array['setting_name'] = 'pna';
			$array['value'] = $this->f3->get('POST.pna_url');

			$array['setting_name_alt'] = 'storefront';
			$setting = $device_setting->getSettingByProfileIdCitrix($array);

			if($setting[0]->setting_name == "storefront") {
                            // now we need to delete it first.
                            $result['deleted'] = $device_setting->delete($array);
			} else {
                            // No citrix settings are currently in the database for this profile
                            // We can add it
                            $result['deleted'] = 1;
                        }
                        
		} else {
			// Maybe we have to delete all settings for Citrix
			$array['disabled'] = 1;
			$array['setting_name_alt'] = 'pna';
			$setting = $device_setting->getSettingByProfileIdCitrix($array);			

			if($setting[0]->setting_name == "pna") {
                            // now we need to delete it first.
                            $result['deleted'] = $device_setting->delete($array);
			}

			$array['setting_name_alt'] = 'storefront';
			$setting = $device_setting->getSettingByProfileIdCitrix($array);

			if($setting[0]->setting_name == "storefront") {
                            // now we need to delete it first.
                            $result['deleted'] = $device_setting->delete($array);
			}

			// we had nothing to update
			$this->f3->reroute('/profile/update/'.$array['iddevice_profile']);
		}

		
		if(($result['deleted'] == 1) && ($array['disabled'] != 1)) {
			$result['inserted'] = $device_setting->edit($array);


			if($result['inserted'] == 1) {
	                	$this->f3->reroute('/profile/success/Citrix setting updated');
			} else {
				$this->f3->reroute('/profile/failed/Citrix setting couldn\'t updated');
			}
		} else {
			$this->f3->reroute('/profile/failed/Something went wrong to delete the previous Citrix setting.');			
		}



        } else {
	    $array['iddevice_profile'] = $this->f3->get('PARAMS.id');
	    $array['categorie'] = 'Citrix';

            $this->f3->set('page_head', $this->f3->get('page_head_ctx_settings'));
	    $this->f3->set('device_profile_settings', $device_setting->getByProfileIdCitrix($array));
	    $this->f3->set('view', 'profile/profile_ctx.htm');
        }
   }

   function profile_rdp() {
	$device_setting = new DeviceSetting($this->db);
	$array['categorie'] = 'RDP';

	if($this->f3->exists('POST.update')) {
		$array['iddevice_profile'] = $this->f3->get('POST.profile_id');
		$array['disable'] = $this->f3->get('POST.check_disable');
		$array['session_user'] = $this->f3->get('SESSION.user');

		// check if this setting is disabled
		if(isset($array['disable'])) {
			// check if the user clicked to disable this setting
			if($device_setting->getNumberOfRows($array) == 0) {
				// now we can reroute this guy, because it's disabled
				$this->f3->reroute('/profile/warning/'.$this->f3->get('setting_disabled'));
			} else {
				// we need to delete the settings.
				$rdp_setting = $device_setting->getByProfileIdRdp($array);
				foreach ($rdp_setting as $key) {
					//echo $key['setting_name'];
					//echo $key['value'];
					$array['setting_name_alt'] = $key['setting_name'];
					$device_setting->delete($array);
				}
				
			}
		} else {
			// check if Citrix disabled. Citrix is disabled if we can't find any setting for this profile.
			$array['categorie'] = 'Citrix';
			if($device_setting->getNumberOfRows($array) == 0) {
				$array['categorie'] = 'RDP';
	
				$count = 1;
				for($i = 0; $i <= $count; $i++) {
					if($i == 0) {
						$array['setting_name'] = 'rdp_url';
						$array['value'] = $this->f3->get('POST.rdp_url');
					} else {
						$array['setting_name'] = 'rdp_domain';
						$array['value'] = $this->f3->get('POST.rdp_domain');
					}
					// insert data
					$result += $device_setting->edit($array);
				}

				if($result == 2) {
					$this->f3->reroute('/profile/success/'.$this->f3->get('reroute_rdp_profile_success'));
				} else {
					$this->f3->reroute('/profile/failed/'.$this->f3->get('reroute_rdp_profile_failed'));
				}
			} else {
				// we found some citrix settings... not good.
				$this->f3->reroute('/profile/failed/'.$this->f3->get('reroute_rdp_profile_citrix_failed'));
			}
		}
	} else {

	    $array['iddevice_profile'] = $this->f3->get('PARAMS.id');		

            $this->f3->set('page_head', $this->f3->get('page_head_rdp_settings'));
	    $this->f3->set('device_profile_settings', $device_setting->getByProfileIdRdp($array));
	    $this->f3->set('device_profile_setting_count', $device_setting->getNumberOfRows($array));
	    $this->f3->set('view', 'profile/profile_rdp.htm');

	}
   }



   function profile_security() {
	$device_setting = new DeviceSetting($this->db);

	if($this->f3->exists('POST.update')) {
		$array['certificate'] = $this->f3->get('POST.cert');
		$array['iddevice_profile'] = $this->f3->get('POST.profile_id');
		$array['session_user'] = $this->f3->get('SESSION.user');
		$array['categorie'] = $this->f3->get('POST.setting_categorie_name');


		$web = \Web::instance();
		$formFieldName = $array['certificate'];

		$overwrite = true; // set to true, to overwrite an existing file; Default: false
		$slug = true; // rename file to filesystem-friendly version

		$files = $web->receive(function($file,$formFieldName){

			// for certificates the following types are possible:
			// - application/x-x509-ca-cert
			// - application/pkix-cert

			// maybe you want to check the file size
        		if(($file['type'] == 'application/x-x509-ca-cert') || ($file['type'] == 'application/pkix-cert'))
            			return true; // this file is valid, return true

        		// file is invalid
        		return false;
		},
    		$overwrite,
    		$slug
		);

		foreach($files as $x => $x_value) {
			// debugging
    			//echo "Key=" . $x . ", Value=" . $x_value;
			//echo "<br>";
			$array['value'] = $x;
			$array['certificate_uploaded'] = $x_value;
	  	}

		if($array['certificate_uploaded'] == 1) {
			// upload was successfull
			$array['setting_name'] = 'certificate';
			$result = $device_setting->edit($array);

			if($result == 1) {
				$this->f3->reroute('/profile/success/'.$this->f3->get('reroute_sec_profile_success'));
			} else {
				$this->f3->reroute('/profile/failed/'.$this->f3->get('reroute_sec_profile_failed'));
			}
		} else {
			$this->f3->reroute('/profile/failed/'.$this->f3->get('reroute_sec_profile_warning'));
		}

	} else {
		$array['iddevice_profile'] = $this->f3->get('PARAMS.id');
		$array['categorie'] = 'Security';

		$this->f3->set('page_head', $this->f3->get('page_head_security_settings'));
		$this->f3->set('certificates', $device_setting->getByProfileIdCitrix($array));
		$this->f3->set('view', 'profile/profile_security.htm');
	}
   }


   /**
    * @todo	implement enery management display
    */
   function profile_system() {
	if($this->f3->exists('POST.update')) {
		$device_setting = new DeviceSetting($this->db);
		$array['categorie'] = $this->f3->get('POST.setting_categorie_name');
		$array['iddevice_profile'] = $this->f3->get('POST.profile_id');
		$array['session_user'] = $this->f3->get('SESSION.user');

		$count = 0;

		// add language
		$tmp = $this->f3->get('POST.language');
		$array['setting_name_alt'] = 'language';
		$settings = $device_setting->getSettingByProfileIdCitrix($array);
		if(isset($tmp) && ($settings[0]['value'] != $tmp)) {
			$array['setting_name'] = 'language';
			$array['value'] = $this->f3->get('POST.language');
			$result += $device_setting->edit($array);
			$count++;
		} 

		// add keyboard
		$tmp = $this->f3->get('POST.keyboard');
		$array['setting_name_alt'] = 'keyboard';
		$settings = $device_setting->getSettingByProfileIdCitrix($array);
		if(isset($tmp) && ($settings[0]['value'] != $tmp)) {
			$array['setting_name'] = 'keyboard';
			$array['value'] = $this->f3->get('POST.keyboard');
			$result += $device_setting->edit($array);
			$count++;
		}

		// add timeserver
		$tmp = $this->f3->get('POST.timeserver');
		$array['setting_name_alt'] = 'timeserver';
		$settings = $device_setting->getSettingByProfileIdCitrix($array);
		if(isset($tmp) && (!empty($tmp))) {
			$array['setting_name'] = 'timeserver';
			$array['value'] = $this->f3->get('POST.timeserver');
			$result += $device_setting->edit($array);
			$count++;
		} elseif(empty($tmp) && ($settings[0]['value'] != '')) {
			// we have to delete the dataset
			$device_setting->deleteById($settings[0]['iddevice_profile_settings']);
		} else {
			// Nothing to do.
		}

		// add management point
		$tmp = $this->f3->get('POST.mgmtpoint');
		$array['setting_name_alt'] = 'mgmtpoint';
		$settings = $device_setting->getSettingByProfileIdCitrix($array);
		if(isset($tmp) && (!empty($tmp))) {
			$array['setting_name'] = 'mgmpoint';
			$array['value'] = $this->f3->get('POST.mgmtpoint');
			$result += $device_setting->edit($array);
			$count++;
		} elseif(empty($tmpy) && ($settings[0]['value'] != '')) {
			// we have to delete the dataset
			$device_setting->deleteById($settings[0]['iddevice_profile_settings']);
		} else {
			// Nothing to do.
		}
		
		
		// add time zone
		$tmp = $this->f3->get('POST.timezone');
		$array['setting_name_alt'] = 'timezone';
		$settings = $device_setting->getSettingByProfileIdCitrix($array);
		if(isset($tmp)&& ($settings[0]['value'] != $tmp)) {
			$array['setting_name'] = 'timezone';
			$array['value'] = $this->f3->get('POST.timezone');
			$result += $device_setting->edit($array);
			$count++;
		}
		


		if($result == $count) {
			$this->f3->reroute('/profile/success/'.$this->f3->get('reroute_sys_profile_success'));
		} else {
			$this->f3->reroute('/profile/failed/'.$this->f3->get('reroute_sys_profile_failed'));
		}
	

	} else {
		$device_setting = new DeviceSetting($this->db);

		$array['iddevice_profile'] = $this->f3->get('PARAMS.id');
		$array['categorie'] = 'System';

		$this->f3->set('page_head', $this->f3->get('page_head_system_settings'));
		$this->f3->set('systems', $device_setting->getByProfileIdCitrix($array));
		$this->f3->set('view', 'profile/profile_system.htm');
	}
   }
   

   function delete_profile_security() {
	$device_setting = new DeviceSetting($this->db);

	$result = $device_setting->deleteById($this->f3->get('PARAMS.id'));

	if($result > 0) {
		$this->f3->reroute('/profile/success/'.$this->f3->get('reroute_sec_profile_delete_success'));
	} else {
		$this->f3->reroute('/profile/failed/'.$this->f3->get('reroute_sec_profile_delete_failed'));
	}
   }
}
