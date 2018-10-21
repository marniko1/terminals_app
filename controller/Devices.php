<?php

class Devices extends BaseController {
	public function index () {
		$this->data['title'] = 'Devices';
		$this->data['devices'] = DBDevices::getAllDevices();
		$this->show_view('devices');
	}
}