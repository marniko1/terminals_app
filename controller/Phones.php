<?php

class Phones extends BaseController {
	public function __construct () {
		$this->data['title'] = 'Phones';
	}
	public function index () {
		$this->data['phones'] = DBPhones::getAllPhones();
		$this->show_view('phones_page_1');
	}
	public function showPageNumTwo () {
		$this->data['phones_models'] = DBModels::getAllPhonesModels();
		$this->show_view('phones_page_2');
	}
	public function addNewPhone ($model_id, $imei) {
		$req = DBPhones::addNewPhone($model_id, $imei);
		if ($req) {
		// if (false) {
			Msg::createMessage("msg1", "Success.");
		} else {
			Msg::createMessage("msg1", "Unsuccess.");
		}
		header("Location: ".INCL_PATH."Phones/panel");
	}
}