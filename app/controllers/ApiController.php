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
        echo $api->idcommand_jobs;
        $api->setJobState($api->idcommand_jobs, 'pending');
        $this->f3->set('view', 'api/default.html');
        echo json_encode($api->cast());
    }
    
    function device_state() {
        $api = new Job($this->db);
        $device = new Device($this->db);
        $device->getByMac($this->f3->get('PARAMS.mac'));
        $api->setDeviceState($this->f3->get('PARAMS.state'), $device->iddevice, $this->f3->get('PARAMS.ip'), $this->f3->get('PARAMS.id'));
        $this->f3->set('view', 'api/default.html');
        echo json_encode($api->cast());
    }
}

