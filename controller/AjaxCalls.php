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

	public function terminalFilter () {
		$response = DBTerminals::getFilteredTerminalsNum($this->search_value);
		echo json_encode($response);
	}

	public function pdaFilter () {
		$response = DBDevices::getFilteredPDA($this->search_value);
		echo json_encode($response);
	}

	public function printerFilter () {
		$response = DBDevices::getFilteredPrinters($this->search_value);
		echo json_encode($response);
	}

	public function simFilter () {
		$response = DBSIM::getFilteredSIM($this->search_value);
		echo json_encode($response);
	}

	public function submitForm(){
		
	}
}