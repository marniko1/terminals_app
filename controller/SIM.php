<?php

class SIM extends BaseController {
	public function index () {
		$this->data['title'] = 'SIM';
		$this->data['sim_cards'] = DBSIM::getAllSIM();
		$this->show_view('sims');
	}
}