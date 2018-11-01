<?php

class Charges extends BaseController {
	public function __construct () {
		$this->data['title'] = 'Charges';
	}
	public function index () {
		$this->show_view('charges_page_1');
	}
	public function showPageNumTwo () {
		$this->show_view('charges_page_2');
	}
	public function makeCharge ($off_num, $agent, $terminal_num, $sim_num, $phone, $phone_model) {
		$req = DBCharges::makeNewCharge($agent, $off_num, intval($terminal_num), intval($sim_num), $phone, $_SESSION['user_id']);
		if ($req) {
		// if (false) {
			Msg::createMessage("msg1", "Success.");
		} else {
			Msg::createMessage("msg1", "Unsuccess.");
		}
		Mail::sendMail('charge', $agent, $off_num, $terminal_num, substr($sim_num, -4), $phone, $phone_model);
		header("Location: ".INCL_PATH."Charges/index");
	}
	public function discharge ($comment, $agent_id, $terminal = 0, $sim = 0, $phone = 0, $inactive = 0, $agent, $off_num, $terminal_num = '', $sim_num = '', $imei = '', $phone_model = '') {
		$req = DBCharges::makeDischarge($agent_id, intval($terminal), intval($sim), intval($phone), intval($inactive), $_SESSION['user_id']);
		if ($req) {
		// if (false) {
			Msg::createMessage("msg1", "Success.");
		} else {
			Msg::createMessage("msg1", "Unsuccess.");
		}
		Mail::sendMail('discharge', $agent, $off_num, $terminal_num, substr($sim_num, -4), $imei, $phone_model, intval($terminal), intval($sim), intval($phone), $comment);
		header("Location: ".INCL_PATH."Agents/$agent_id");
	}
}