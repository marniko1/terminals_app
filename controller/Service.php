<?php

class Service extends BaseController {
	public function __construct () {
		parent::__construct();
		$this->data['title'] = 'Service';
	}
	public function index () {
		// $this->data['title'] = 'Service';
		// $this->data['terminals'] = DBTerminals::getAllTerminals();
		$this->show_view('service_home');
	}
	public function showServiceActionPage () {
		// $this->data['title'] = 'Service';
		// $this->data['terminals'] = DBTerminals::getAllTerminals();
		$this->show_view('service_actiones');
	}
	public function showServiceAdminPage () {
		//$this->data['users'] = DBUsers::getAllUsers();
		$this->show_view('service_admin');
	}
}