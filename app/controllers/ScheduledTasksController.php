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
    
    /**
     * 
     * @param type $time
     * @return type
     */
    function split_time($time) {
        preg_match("/([0-9]{1,2}):([0-9]{1,2})/", $time, $match);
        return $match;
 
    }
    
    function afterroute() {
        echo Template::instance()->render('layout.htm');
    }
    
    function index() {
        
        $scheduled_task = new ScheduledTasks($this->db);
        
        $this->f3->set('scheduled_tasks', $scheduled_task->all());
        $this->f3->set('message', $this->f3->get('PARAMS.message'));
	$this->f3->set('message_warning', $this->f3->get('PARAMS.message_warning'));
	$this->f3->set('message_failed', $this->f3->get('PARAMS.message_failed'));
        $this->f3->set('page_head', $this->f3->get('page_head_scheduled_tasks_overview'));
	$this->f3->set('view', 'scheduled_tasks/list.htm');
    }
    
    function byState() {
        $scheduled_task = new ScheduledTasks($this->db);
        
        $this->f3->set('scheduled_tasks', $scheduled_task->byState($this->f3->get('PARAMS.state')));
        $this->f3->set('page_head', $this->f3->get('page_head_scheduled_tasks_overview'));
	$this->f3->set('view', 'scheduled_tasks/list.htm');
    }
    
    function create() {
        if($this->f3->exists('POST.create')) {
        
            $scheduled_task = new ScheduledTasks($this->db);
            
            // get all variables from the form
            $array['task_name'] = $this->f3->get('POST.task_name');
            $array['command'] = $this->f3->get('POST.command');
            $array['description'] = $this->f3->get('POST.description');
            $array['state'] = $this->f3->get('POST.state');
            $array['start_date'] = date("Y-m-d", strtotime($this->f3->get('POST.start_date')));
            $array['end_date_state'] = $this->f3->get('POST.end_date_state');
            $array['end_date'] = date("Y-m-d",strtotime($this->f3->get('POST.end_date')));
            $array['execution_time'] = date("H:i",strtotime($this->f3->get('POST.execution_time')));
            $array['repeat_task'] = $this->f3->get('POST.optionsRadios');
            $array['task_repeat_times'] = $this->f3->get('POST.task_repeat_times');
            $array['type_of_repeat'] = $this->f3->get('POST.type_of_repeat');
            $array['weekdays'] = $this->f3->get('POST.weekdays');
            $array['groups'] = $this->f3->get('POST.groups');
            $array['user'] = $this->f3->get('SESSION.user');
                    
            
            /* debugging
            print_r('Name: '.$array['task_name'].'<br>');
            print_r('Kommando: '.$array['command'].'<br>');
            print_r('Beschreibung: '.$array['description'].'<br>');
            print_r('Status: '.$array['state'][0].'<br>');
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
            print_r('<br>Gruppen: ');
            var_dump($array['groups']);
             * 
             */
            
            $add_scheduled_task = array();
            $add_scheduled_task['task_name'] = $array['task_name'];
            $add_scheduled_task['command'] = $array['command'];
            $add_scheduled_task['description'] = $array['description'];
            $add_scheduled_task['user'] = $array['user'];
            
            
            // set state
            if($array['state'][0] == "0") {
                $add_scheduled_task['state'] = "activated";
            } else {
                $add_scheduled_task['state'] = "deactivated";
            }
            
            $add_scheduled_task['startdate'] = $array['start_date']. ' '. $array['execution_time'];
            
            // Set enddate as null if it doesn't exist
            // We set enddate as the same then the startdate. So we know that this task has to run only once.
            
            if($array['end_date'] = "1970-01-01") {
                $add_scheduled_task['enddate'] = NULL;
            }
            
            
            // Set execution plan
            if($array['repeat_task'] == 'never') {
                // The task is running only once
                $add_scheduled_task['enddate'] = $add_scheduled_task['startdate'];
                $add_scheduled_task['minute'] = 0;
                $add_scheduled_task['hour'] = 0;
                $add_scheduled_task['day_of_month'] = 0;
                $add_scheduled_task['month'] = 0;
                $add_scheduled_task['weekday'] = 0;
            } else {                
                // The task is running every 'n' minute(s)
                if($array['type_of_repeat'] == 'minute') {
                    if($array['task_repeat_times'] == 1) {
                        $add_scheduled_task['minute'] = "*";
                    } else {
                        $add_scheduled_task['minute'] = "*/".$array['task_repeat_times'];
                    }
                    $add_scheduled_task['hour'] = "*";
                    $add_scheduled_task['day_of_month'] = "*";
                    $add_scheduled_task['month'] = "*";
                    $add_scheduled_task['weekday'] = "*";
                }
                
                // The task is running every 'n' hour(s)
                if($array['type_of_repeat'] == 'hour') {
                    if($array['task_repeat_times'] == 1) {
                        $add_scheduled_task['hour'] = "*";
                    } else {
                        $add_scheduled_task['hour'] = "*/".$array['task_repeat_times'];
                    }
                    $add_scheduled_task['minute'] = "*";
                    $add_scheduled_task['day_of_month'] = "*";
                    $add_scheduled_task['month'] = "*";
                    $add_scheduled_task['weekday'] = "*";
                }
                
                // The task is running every 'n' day(s) 
                if($array['type_of_repeat'] == 'day') {
                    if($array['task_repeat_times'] == 1) {
                        $add_scheduled_task['day_of_month'] = "*";                      
                    } else {
                        $add_scheduled_task['day_of_month'] = "*/".$array['task_repeat_times'];
                    }
                    
                    // Split clock
                    $match = $this->split_time($array['execution_time']);
                    $add_scheduled_task['hour'] = $match[1];
                    $add_scheduled_task['minute'] = $match[2];
                    $add_scheduled_task['month'] = "*";
                    $add_scheduled_task['weekday'] = "*";
                }
                
                // The task is running every 'n' week(s)
                if($array['type_of_repeat'] == 'week') {
                    
                    if(count($array['weekdays']) == 7) {
                        $add_scheduled_task['weekday'] = "*";
                    } else {
                        foreach($array['weekdays'] as $key => $weekday) {
                            if($key < count($array['weekdays'])) {
                                $add_scheduled_task['weekday'] .= $weekday.",";
                            } else {
                                $add_scheduled_task['weekday'] .= $weekday;
                            }
                        }
                    }
                    
                    $match = $this->split_time($array['execution_time']);
                    $add_scheduled_task['hour'] = $match[1];
                    $add_scheduled_task['minute'] = $match[2];
                    $add_scheduled_task['month'] = "*";
                    $add_scheduled_task['day_of_month'] = "*";
                }
                
                
            }
            
            // Build the group string for our stored procedure
            for($i = 0; $i < count($array['groups']); $i++) {
                if($i == (count($array['groups'])-1)) {
                    $add_scheduled_task['device_groups'] .= $array['groups'][$i];
                } else {
                    $add_scheduled_task['device_groups'] .= $array['groups'][$i].'#';
                }
            }
            
            //debugging
            print_r('<br>Array to add task: ');
            var_dump($add_scheduled_task);
            
            
            $result = $scheduled_task->add($add_scheduled_task);
            
            if($result == 1) {
                // all is running perfect, no errors
                $this->f3->reroute('/system/scheduled-tasks/success/'.$this->f3->get('reroute_scheduled_task_success'));
            } else {
                $this->f3->reroute('/system/scheduled-tasks/failed/'.$this->f3->get('reroute_scheduled_task_failed'));

            }
            
            
            
        } else {
            $command = new Command($this->db);
            $device_groups = new DeviceGroup($this->db);
            
            $this->f3->set('commands', $command->getByScheduledTasks('1'));
            $this->f3->set('device_groups', $device_groups->all());
            $this->f3->set('language', substr($this->f3->get('LANGUAGE'), 0, 2));
            $this->f3->set('page_head', $this->f3->get('page_head_scheduled_tasks_create'));
            $this->f3->set('view', 'scheduled_tasks/create.htm');
        }
    }
}
    