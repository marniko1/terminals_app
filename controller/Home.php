<?php

class Home extends BaseController {
	public function __construct () {
		parent::__construct();
		$this->data['title'] = 'Home';
	}
	public function index () {
		$this->data['terminals_num'] = DBTerminals::countAllTerminals();
		$this->data['terminals_num_in_storage'] = DBTerminals::countAllTerminalsInStorage();
		$this->data['charged_terminals_num'] = DBTerminals::countAllChargedTerminals();

		$this->data['pda_num'] = DBDevices::countAllPDA();
		$this->data['pda_num_in_storage'] = DBDevices::countAllPDAInService();
		$this->data['pda_num_in_terminals'] = DBDevices::countAllPDAInTerminals();
		$this->data['pda_num_on_other_locations'] = DBDevices::countAllPDAOnOtherLocations();

		$this->data['printers_num'] = DBDevices::countAllPrinters();
		$this->data['printers_num_in_storage'] = DBDevices::countAllPrintersInService();
		$this->data['printers_num_in_terminals'] = DBDevices::countAllPrintersInTerminals();
		$this->data['printers_num_on_other_locations'] = DBDevices::countAllPrintersOnOtherLocations();
		$this->show_view('home');
	}
}