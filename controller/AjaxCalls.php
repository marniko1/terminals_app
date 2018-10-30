<?php

class AjaxCalls extends BaseController {

	public $method;
	public $pg;
	public $id;
	public $skip;
	public $search_value;
	public $params = [];

	public function __construct () {
		$this->method = $_POST['ajax_fn'];
		if (isset($_POST['pg'])) {
			$this->pg = $_POST['pg'];
			$this->skip = $_POST['pg']*PG_RESULTS-PG_RESULTS;
		}
		if (isset($_POST['search_value'])) {
			$this->search_value = $_POST['search_value'];
		}
		if (isset($_POST['id'])) {
			$this->id = $_POST['id'];
		}
	}

	public function index () {
		$method = $this->method;
		$this->$method();
	}

	public function terminalNumFilter () {
		$response = DBTerminals::getFilteredTerminalsNum($this->search_value);
		echo json_encode($response);
	}

	public function terminalFilter () {
		$response = DBTerminals::getFilteredTerminals($this->search_value);
		echo json_encode($response);
	}

	public function pdaFilter () {
		$response = DBDevices::getFilteredPDA($this->search_value);
		echo json_encode($response);
	}

	public function printerFilter () {
		$response = DBDevices::getFilteredPrinter($this->search_value);
		echo json_encode($response);
	}

	public function pdaSimFilter () {
		$response = DBSIM::getFilteredSIMForPDA($this->search_value);
		echo json_encode($response);
	}

	public function simFilter () {
		$response = DBSIM::getFilteredSIM($this->search_value);
		echo json_encode($response);
	}

	public function phoneFilter () {
		$response = DBPhones::getFilteredPhones($this->search_value);
		echo json_encode($response);
	}

	public function agentsFilter () {
		$filtered_data = DBAgents::getFilteredAgents('agent', $this->search_value, $this->skip);
		$this->ajaxResponse($filtered_data);
	}

	public function devicesFilter () {
		$filtered_data = DBDevices::getFilteredDevices('device', $this->search_value, $this->skip);
		$this->ajaxResponse($filtered_data);
	}

	public function simsFilter () {
		$filtered_data = DBSIM::getFilteredSIMs('sim', $this->search_value, $this->skip);
		$this->ajaxResponse($filtered_data);
	}

	public function checkAgentByOffNum () {
		$response = DBAgents::getAgentByOffNum($this->search_value);
		echo json_encode($response);
	}

	public function submitForm(){
		
	}

	public function ajaxResponse ($filtered_data) {
		$total_num = 0;
		if (isset($filtered_data[0]->total)) {
			$total_num = $filtered_data[0]->total;
		}
		$pagination_data = $this->preparePaginationLinks($total_num, $this->pg);
		$response = [$filtered_data, $pagination_data, $this->skip];
		echo json_encode($response);
	}
}