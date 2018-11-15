<?php

class Terminals extends BaseController {
	public function __construct () {
		parent::__construct();
		$this->data['title'] = 'Terminals';
	}
	public function index ($pg = 1) {
		if ($pg !== 1) {
			$pg = substr($pg, 1);
			$this->skip = $pg*PG_RESULTS-PG_RESULTS;
		}
		$this->data['terminals'] = DBTerminals::getAllTerminals($this->skip);
		$total_devices_num = $this->data['terminals'][0]->total;
		$this->data['pagination_links'] = $this->preparePaginationLinks($total_devices_num, $pg);
		$this->show_view('terminals_page_1');
	}
	public function showPageNumTwo() {
		$this->show_view('terminals_page_2');
	}
	public function showSingleTerminal($terminal_id) {
		$this->data['terminal'] = DBTerminals::getSingleTerminal($terminal_id);
		$this->show_view('terminal');
	}
	public function addNewTerminal ($terminal_num, $pda, $printer, $sim) {
		$req = DBTerminals::addNewTerminal($terminal_num, $pda, $printer, $sim, $_SESSION['user_id']);
		if ($req) {
		// if (false) {
			Msg::createMessage("msg1", "Success.");
		} else {
			Msg::createMessage("msg1", "Unsuccess.");
		}
		header("Location: ".INCL_PATH."Terminals/panel");
	}
	public function removeTerminal ($id) {
		$req = DBTerminals::removeTerminal($id, $_SESSION['user_id']);
		if ($req) {
		// if (false) {
			Msg::createMessage("msg1", "Success.");
		} else {
			Msg::createMessage("msg1", "Unsuccess.");
		}
		header("Location: ".INCL_PATH."Terminals/index");
	}
}