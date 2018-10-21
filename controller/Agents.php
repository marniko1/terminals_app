<?php

class Agents extends BaseController {
	public function __construct () {
		$this->data['title'] = 'Agents';
	}
	public function index () {
		$this->data['agents'] = DBAgents::getAllAgents();
		$this->show_view('agents');
	}
	public function showSingleAgent ($id) {
		$this->data['agent'] = DBAgents::getSingleAgent($id);
		$this->show_view('agent');
	}
}