<?php

/**
 * @file   ReportsControllerController.php
 * @brief  C8.01.2017
 * @author Raphael Lekies (IT4S GmbH) <raphael.lekies@it4s.eu>
 */


/**
 * @class	ReportsController
 */

class ReportsController extends Controller {
    function afterroute() {
        echo Template::instance()->render('layout.htm');
    }
    
    function overview_jobs() {
        $reports = new Reports($this->db);

        $subset = $reports->getOverviewJobs();
        $pages = new Pagination($subset['total'], $subset['limit']);
        
        $this->f3->set('page_head', $this->f3->get('page_head_reports_overview_jobs'));
        $this->f3->set('report_states', $reports->getOverviewJobStates());
	$this->f3->set('report_oj', $subset);
        $this->f3->set('pagebrowser', $pages->serve());
        $this->f3->set('view', 'reports/overview-jobs.htm');
    }
    
    function byFilterState() {
        $reports = new Reports($this->db);

        //print_r($reports->getOverviewJobsByState($this->f3->get('PARAMS.filter')));
        $subset = $reports->getOverviewJobsByState($this->f3->get('PARAMS.filter'));
        $pages = new Pagination($subset['total'], $subset['limit']);
        
        $this->f3->set('page_head', $this->f3->get('page_head_reports_overview_jobs'));
        $this->f3->set('report_states', $reports->getOverviewJobStates());
	$this->f3->set('report_oj', $subset);
        $this->f3->set('pagebrowser', $pages->serve());
        $this->f3->set('view', 'reports/overview-jobs.htm');
    }
}
    