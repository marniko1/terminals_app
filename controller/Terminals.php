<?php

class Terminals extends BaseController {
	public function index () {
		$this->data['title'] = 'Terminals';
		$this->data['terminals'] = DBTerminals::getAllTerminals();
		$this->show_view('terminals_page_1');
	}
	public function showPageNumTwo() {
		$this->data['title'] = 'Terminals';
		$this->show_view('terminals_page_2');
	}
	public function showSingleTerminal($terminal_id) {
		$this->data['title'] = 'Terminals';
		$this->data['terminal'] = DBTerminals::getSingleTerminal($terminal_id);
		$this->show_view('terminal');
	}
	public function addNewTerminal ($terminal_num, $pda, $printer, $sim) {
		$req = DBTerminals::addNewTerminal($terminal_num, $pda, $printer, $sim);
		if ($req) {
		// if (false) {
			Msg::createMessage("msg1", "Success.");
		} else {
			Msg::createMessage("msg1", "Unsuccess.");
		}
		header("Location: ".INCL_PATH."Terminals/panel");
	}
	public function removeTerminal ($id) {
		$req = DBTerminals::removeTerminal($id);
		if ($req) {
		// if (false) {
			Msg::createMessage("msg1", "Success.");
		} else {
			Msg::createMessage("msg1", "Unsuccess.");
		}
		header("Location: ".INCL_PATH."Terminals/index");
	}
}