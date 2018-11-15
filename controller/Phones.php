<?php

class Phones extends BaseController {
	public function __construct () {
		$this->data['title'] = 'Phones';
	}
	public function index ($pg = 1) {
		if ($pg !== 1) {
			$pg = substr($pg, 1);
			$this->skip = $pg*PG_RESULTS-PG_RESULTS;
		}
		$this->data['phones'] = DBPhones::getAllPhones($this->skip);
		$total_sims_num = $this->data['phones'][0]->total;
		$this->data['pagination_links'] = $this->preparePaginationLinks($total_sims_num, $pg);
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