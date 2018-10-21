<?php

class Charges extends BaseController {
	public function index () {
		$this->data['title'] = 'Charges';
		$this->show_view('charges_page_1');
	}
	public function showPageNumTwo () {
		$this->data['title'] = 'Charges';
		$this->show_view('charges_page_2');
	}
	public function makeCharge ($agent, $off_num, $terminal, $sim = 0, $phone) {
		$req = DBCharges::makeNewCharge($agent, $off_num, intval($terminal), intval($sim), $phone, $_SESSION['user_id']);
		if ($req) {
		// if (false) {
			Msg::createMessage("msg1", "Success.");
		} else {
			Msg::createMessage("msg1", "Unsuccess.");
		}
		header("Location: ".INCL_PATH."Charges/index");
	}
	public function discharge ($comment, $agent_id, $terminal = 0, $sim = 0, $phone = 0, $inactive = 0) {
		// var_dump($comment, $agent_id, intval($terminal), intval($sim), intval($phone), intval($inactive));
		$req = DBCharges::makeDischarge($agent_id, intval($terminal), intval($sim), intval($phone), intval($inactive), $_SESSION['user_id']);
		if ($req) {
		// if (false) {
			Msg::createMessage("msg1", "Success.");
		} else {
			Msg::createMessage("msg1", "Unsuccess.");
		}
		header("Location: ".INCL_PATH."Agents/$agent_id");
	}
}