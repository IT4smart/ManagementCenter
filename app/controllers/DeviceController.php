<?php

/**
 * @file   DeviceController.php
 * @brief  Controller to handle devices.
 * @date   27.December 2015
 * @author Raphael Lekies <raphael.lekies@it4s.eu>
 */


/**
 * @class	DeviceController
 * @todo	Somewhere we have to add that user's can edit the ip of the device. Maybe with a modal prompt.
 */

class DeviceController extends Controller {
    function afterroute() {
        echo Template::instance()->render('layout.htm');
    }
    
    /**
     * Generate a random string. Default length of the string is 10
     *
     * @param length    The length of the string
     * @return          The generated string,
     */
    function generateRandomString($length = 10) {
      $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
      $charactersLength = strlen($characters);
      $randomString = '';
      for ($i = 0; $i < $length; $i++) {
          $randomString .= $characters[rand(0, $charactersLength - 1)];
      }
      return $randomString;
    } 

    /**
     * Check if given ipv4 is valid
     *
     * @param ip	The ip that is to check
     * @return		If a syntactically invalid address is given the return value is FALSE
     */	
    function validateIp($ip) {
	return inet_pton($ip);
    }

    /**
     * Check if given mac address is valid
     *
     * @param mac	The MAC - Address that is to check
     * @return		If it is valid we give a '1' back.
     */
    function validateMac($mac) {
  	return (preg_match('/([a-fA-F0-9]{2}[:|\-]?){6}/', $mac) == 1);
    }


    function index() {
        $device = new Device($this->db);
	$devicegroup = new DeviceGroup($this->db);
	$this->f3->set('devices', $device->all());
	$this->f3->set('devicegroups', $devicegroup->all());
	$this->f3->set('message', $this->f3->get('PARAMS.message'));
	$this->f3->set('message_warning', $this->f3->get('PARAMS.message_warning'));
	$this->f3->set('message_failed', $this->f3->get('PARAMS.message_failed'));
        $this->f3->set('page_head', 'Device Overview');
	$this->f3->set('view', 'device/list.htm');

    }


    function byFilter() {
	$device = new Device($this->db);
	$device->byStatus($this->f3->get('PARAMS.filter'));
    }


    function detail() {
	$device = new Device($this->db);
	$device_profile = new DeviceProfile($this->db);
	$device_assignment = new DeviceAssignment($this->db);

	// get all information for device_log
	$array['lang'] = substr($this->f3->get('LANGUAGE'), 0, 2);
	$array['device_name'] = $this->f3->get('PARAMS.devicename');
	
	$this->f3->set('devices', $device->getByName($this->f3->get('PARAMS.devicename')));
	$this->f3->set('device_groups', $device_assignment->getByDeviceName($array['device_name']));
	$this->f3->set('device_profiles', $device_profile->getProfilesSummaryByDeviceName($array['device_name']));
	$this->f3->set('device_logs', $device->getDeviceLog($array));
	$this->f3->set('page_head', 'Detailed  view of '.$this->f3->get('PARAMS.devicename'));
	$this->f3->set('view', 'device/detail_summary.htm');
    }

    function create() {
        if($this->f3->exists('POST.create')) {

	    $web = \Web::instance();

	    $array['devicename'] = $this->f3->get('POST.devicename');
            $array['devicetype'] = $this->f3->get('POST.devicetype');
	    $array['mac'] = $this->f3->get('POST.mac');
	    $array['ip'] = $this->f3->get('POST.ip');
	    $array['devicegroup'] = $this->f3->get('POST.devicegroup');
	    $array['serialnumber'] = $this->f3->get('POST.serialnumber');
	    $array['note'] = $this->f3->get('POST.note');
	    $array['photo'] = $this->f3->get('POST.photo');
	    $array['session_user'] = $this->f3->get('SESSION.user');

	    if($array['photo'] != '') {
	    	$formFieldName = $array['photo'];

		$overwrite = false; // set to true, to overwrite an existing file; Default: false
	    	$slug = true; // rename file to filesystem-friendly version

	    	$files = $web->receive(function($file,$formFieldName){

	     	//debugging	
             	//var_dump($file);
             	/* looks like:
              	array(5) {
                  ["name"] =>     string(19) "csshat_quittung.png"
                  ["type"] =>     string(9) "image/png"
                  ["tmp_name"] => string(14) "/tmp/php2YS85Q"
                  ["error"] =>    int(0)
                  ["size"] =>     int(172245)
              	}
             	*/
             	// $file['name'] already contains the slugged name now

             	// maybe you want to check the file size
             	if($file['size'] > (2 * 1024 * 1024)) // if bigger than 2 MB
              	  return false; // this file is not valid, return false will skip moving it

              	// everything went fine, hurray!
              	return true; // allows the file to be moved from php tmp dir to your defined upload dir
    	   	},
    	   	$overwrite,
    	   	function($fileBaseName, $formFieldName){
			// build new file name from base name or input field name
			// get extension
			preg_match('/\.[^\.]+$/i',$fileBaseName,$ext); 

			// set new indivual filename
			$file_new = $this->generateRandomString().$ext[0];
			return $file_new;
		}
	  	);

	  	//debugging
	  	//var_dump($files);

	  	foreach($files as $x => $x_value) {
			// debugging
    			//echo "Key=" . $x . ", Value=" . $x_value;
			//echo "<br>";
			$array['photo'] = $x;
			$array['photo_uploaded'] = $x_value;
	  	}

	 	// upload was successfull and ip is valid
	 	if (($array['photo_uploaded'] == 1) && ($this->validateIp($array['ip']) != FALSE) && ($this->validateMac($array['mac']) == 1)) {
	    		// add new device
            		$device = new Device($this->db);
	    		$result = $device->add($array);

	    		//var_dump($result);
            		if($result['result'] == 1) {
	        		$this->f3->reroute('/device/success/'.$this->f3->get('reroute_device_success'));
	    		} else {
				$this->f3->reroute('/device/failed/'.$this->f3->get('reroute_device_failed'));
	    		}
	 	} else {
	  		// upload failed because of filesize
	  		$this->f3->reroute('/device/failed/'.$this->f3->get('reroute_device_file_failed'));
	 	}
	   } else {
		if(($this->validateIp($array['ip']) != FALSE) && ($this->validateMac($array['mac']) == 1)) {
			$device = new Device($this->db);
			$result = $device->add($array);

           		if($result['result'] == 1) {
	        		$this->f3->reroute('/device/success/'.$this->f3->get('reroute_device_success'));
	    		} else {
				$this->f3->reroute('/device/failed/'.$this->f3->get('reroute_device_failed'));
	    		}
		} else {
			$this->f3->reroute('/device/failed/'.$this->f3->get('reroute_device_failed'));
		}
	   }
        } else {

	    $devicetype = new DeviceType($this->db);
	    $devicegroup = new DeviceGroup($this->db);
            $this->f3->set('page_head', 'Create Device');
	    $this->f3->set('devicetypes', $devicetype->all());
	    $this->f3->set('devicegroups', $devicegroup->all());
            $this->f3->set('view', 'device/create.htm');
        }
    }
} 
