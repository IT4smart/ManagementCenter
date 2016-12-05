<?php

/**
 * @file   ScheduledTasksController.php
 * @brief  Controller to handle scheduled tasks.
 * @date   14.10.2016
 * @author Raphael Lekies (IT4S GmbH) <raphael.lekies@it4s.eu>
 */


/**
 * @class	ScheduledTasksController
 * @todo	Somewhere we have to add that user's can edit the ip of the device. Maybe with a modal prompt.
 */

class ScheduledTasksController extends Controller {
    function afterroute() {
        echo Template::instance()->render('layout.htm');
    }
    
    function index() {
        $this->f3->set('page_head', $this->f3->get('page_head_scheduled_tasks_overview'));
	$this->f3->set('view', 'scheduled_tasks/list.htm');
    }
    
    function create() {
        if($this->f3->exists('POST.create')) {
            
        } else {
            $command = new Command($this->db);
            
            $this->f3->set('commands', $command->getByInterval('0'));
            $this->f3->set('language', substr($this->f3->get('LANGUAGE'), 0, 2));
            $this->f3->set('page_head', $this->f3->get('page_head_scheduled_tasks_create'));
            $this->f3->set('view', 'scheduled_tasks/create.htm');
        }
    }
}
    