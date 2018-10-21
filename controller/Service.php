<?php

class Service extends BaseController {
	public function index () {
		$this->data['title'] = 'Service';
		// $this->data['terminals'] = DBTerminals::getAllTerminals();
		$this->show_view('service');
	}
}