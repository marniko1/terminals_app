<?php

class Service extends BaseController {
	public function __construct () {
		parent::__construct();
		$this->data['title'] = 'Service';
	}
	public function index () {
		$this->show_view('service_home');
	}
	public function showServiceActionPage () {
		$this->show_view('service_actiones');
	}
	public function showServiceAdminPage () {
		$this->show_view('service_admin');
	}
}