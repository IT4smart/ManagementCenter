<?php

/**
 * @file   ScheduledTasksController.php
 * @brief  Controller to handle scheduled tasks.
 * @date   14.10.2016
 * @author Raphael Lekies (IT4S GmbH) <raphael.lekies@it4s.eu>
 */


/**
 * @class	ScheduledTasksController
 * @todo	Check the values a user is inserted with javascript and mark the fields with color.
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
        
            // get all variables from the form
            $array['task_name'] = $this->f3->get('POST.task_name');
            $array['command'] = $this->f3->get('POST.command');
            $array['description'] = $this->f3->get('POST.description');
            $array['state'] = $this->f3->get('POST.state');
            $array['start_date'] = $this->f3->get('POST.start_date');
            $array['end_date_state'] = $this->f3->get('POST.end_date_state');
            $array['end_date'] = $this->f3->get('POST.end_date');
            $array['execution_time'] = $this->f3->get('POST.execution_time');
            $array['repeat_task'] = $this->f3->get('POST.optionsRadios');
            $array['task_repeat_times'] = $this->f3->get('POST.s');
            $array['type_of_repeat'] = $this->f3->get('POST.type_of_repeat');
            $array['weekdays'] = $this->f3->get('POST.weekdays');
            
            // debugging
            print_r('Name: '.$array['task_name'].'<br>');
            print_r('Kommando: '.$array['command'].'<br>');
            print_r('Beschreibung: '.$array['description'].'<br>');
            print_r('Status: '.$array['state'].'<br>');
            var_dump($array['state']);
            print_r('<br>Startdatum: '.$array['start_date'].'<br>');
            print_r('Status Enddatum: '.$array['end_date_state'].'<br>');
            var_dump($array['end_date_state']);
            print_r('<br>Enddatum: '.$array['end_date'].'<br>');
            print_r('Ausführungszeit: '.$array['execution_time'].'<br>');
            print_r('Wiederholen?: '.$array['repeat_task'].'<br>');
            print_r('Wiederholungen: '.$array['task_repeat_times'].'<br>');
            print_r('Wiederholungstyp: '.$array['type_of_repeat'].'<br>');
            print_r('Wochentage: '.$array['weekdays'].'<br>');
            var_dump($array['weekdays']);
            
            
            
            
        } else {
            $command = new Command($this->db);
            
            $this->f3->set('commands', $command->getByInterval('0'));
            $this->f3->set('language', substr($this->f3->get('LANGUAGE'), 0, 2));
            $this->f3->set('page_head', $this->f3->get('page_head_scheduled_tasks_create'));
            $this->f3->set('view', 'scheduled_tasks/create.htm');
        }
    }
}
    