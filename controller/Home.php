<?php

class Home extends BaseController {
	public function __construct () {
		parent::__construct();
		$this->data['title'] = 'Home';
	}
	public function index () {
		$this->data['terminals_num'] = DBTerminals::countAllTerminals();
		$this->data['terminals_num_in_storage'] = DBTerminals::countAllTerminalsInStorage();
		$this->data['charged_terminals_num'] = DBTerminals::countAllChargedTerminals();
		$this->show_view('home');
	}
}