<?php

class Agents extends BaseController {
	public function __construct () {
		parent::__construct();
		$this->data['title'] = 'Agents';
	}
	public function index ($pg = 1) {
		if ($pg !== 1) {
			$pg = substr($pg, 1);
			$this->skip = $pg*PG_RESULTS-PG_RESULTS;
		}
		$this->data['agents'] = DBAgents::getAllAgents($this->skip);
		$total_agents_num = $this->data['agents'][0]->total;
		$this->data['pagination_links'] = $this->preparePaginationLinks($total_agents_num, $pg);
		$this->show_view('agents');
	}
	public function showSingleAgent ($id) {
		$this->data['agent'] = DBAgents::getSingleAgent($id);
		$this->show_view('agent');
	}
}