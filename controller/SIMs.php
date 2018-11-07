<?php

class SIMs extends BaseController {
	public function __construct () {
		$this->data['title'] = 'SIM';
	}
	public function index ($pg = 0) {
		$skip = 0;
		if ($pg !== 0) {
			$pg = substr($pg, 1);
			$skip = $pg*PG_RESULTS-PG_RESULTS;
		}
		$this->data['sim_cards'] = DBSIM::getAllSIM($skip);
		$total_sims_num = $this->data['sim_cards'][0]->total;
		$this->data['pagination_links'] = $this->preparePaginationLinks($total_sims_num, $pg);
		$this->show_view('sims');
	}
	public function showAddNewSimPage () {
		$this->show_view('sims_adding');
	}
	public function showSingleSIM($sim_id) {
		$this->data['sim'] = DBSIM::getSingleSIM($sim_id);
		$this->show_view('sim');
	}
	public function addNewSIM ($network, $num, $iccid, $purpose) {
		$req = DBSIM::addNewSIM(381 . $network, $num, $iccid, $purpose);
		if ($req) {
		// if (false) {
			Msg::createMessage("msg1", "Success.");
		} else {
			Msg::createMessage("msg1", "Unsuccess.");
		}
		header("Location: ".INCL_PATH."SIMs/panel");
	}
}