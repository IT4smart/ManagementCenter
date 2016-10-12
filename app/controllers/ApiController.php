<?php

/**
 * @file   ApiController.php
 * @brief  Controller to handle the api requests from the agents.
 * @date   11.August 2016
 * @author Raphael Lekies <raphael.lekies@it4s.eu>
 */

/**
 * @class	ApiController
 */
class Apicontroller extends Controller {
    
    function get_jobs() {
        $api = new Job($this->db);
        $api->getJobByMac($this->f3->get('PARAMS.mac'));
        if (!empty($api->idcommand_jobs)) {
            $api->setJobState($api->idcommand_jobs, 'pending');
        }
        $this->f3->set('view', 'api/default.html');
        echo json_encode($api->cast());
    }
    
    function device_state() {
        $api = new Job($this->db);
        $device = new Device($this->db);
        $device->getByMac($this->f3->get('PARAMS.mac'));
        $api->setDeviceState($this->f3->get('PARAMS.state'), $device->iddevice, $this->f3->get('PARAMS.id'));
        $this->f3->set('view', 'api/default.html');
        echo json_encode($api->cast());
    }
    
    function device_uptime() {
        $api = new Job($this->db);
        $device = new Device($this->db);
        $device->getByMac($this->f3->get('PARAMS.mac'));
        $api->setDeviceUptime($this->f3->get('PARAMS.time'),  $device->iddevice, $this->f3->get('PARAMS.id'));
        $this->f3->set('view', 'api/default.html');
        echo json_encode($api->cast());
    }
    
    /**
     * Insert or update device package data.
     * @todo add support to track upgradeable packages.
     */
    function device_data() {
        $device = new Device($this->db);
        $api = new Job($this->db);
        
        // handle json
        //print_r($this->f3->get('BODY'));
        $obj = json_decode($this->f3->get('BODY'));
           
        foreach($obj as $row) {
            $device->getByMac($row->mac);
            $api->addPackageData($row->package, $row->version, $device->iddevice);
        }
        
        $api->setJobState($obj[0]->id_command_jobs, "success");
        $this->f3->set('view', 'api/default.html');
        echo json_encode($api->cast());
        
    }
    
    /**
     * Registering an unknown device
     */
    function device_register() {
        $api = new Job($this->db);

        $api->addDeviceRegisterJob($this->f3->get('PARAMS.mac'), $this->f3->get('PARAMS.hostname'));
        echo json_encode($api->cast());
    }
    
    /**
     * Get the current state of registering the device
     */
    function getRegisterState() {
        $api = new Job($this->db);
        $result = $api->getRegisterStateByMac($this->f3->get('PARAMS.mac'));
        $this->f3->set('view', 'api/default.html');
        echo json_encode($result);
    }
    
    /**
     * Set state of register job
     */
    function setRegisterState() {
        $api = new Job($this->db);
        $api->setRegisterState($this->f3->get('PARAMS.id'), $this->f3->get('PARAMS.state'));
        $this->f3->set('view', 'api/default.html');
        echo json_encode($api->cast());
    }
    
    /**
     * Reboot device
     */
    function device_reboot() {
        $api = new Job($this->db);
        $api->setJobState($this->f3->get('PARAMS.id'), 'success');
        $this->f3->set('view', 'api/default.html');
        echo json_encode($api->cast());
    }
}

