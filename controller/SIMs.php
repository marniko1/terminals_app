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
}