<?php

class Agents extends BaseController {
	public function __construct () {
		$this->data['title'] = 'Agents';
	}
	public function index ($pg = 0) {
		$skip = 0;
		if ($pg !== 0) {
			$pg = substr($pg, 1);
			$skip = $pg*PG_RESULTS-PG_RESULTS;
		}
		$this->data['agents'] = DBAgents::getAllAgents($skip);
		$total_agents_num = $this->data['agents'][0]->total;
		$this->data['pagination_links'] = $this->preparePaginationLinks($total_agents_num, $pg);
		$this->show_view('agents');
	}
	public function showSingleAgent ($id) {
		$this->data['agent'] = DBAgents::getSingleAgent($id);
		$this->show_view('agent');
	}
}