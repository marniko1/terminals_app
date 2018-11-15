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
// for proposals
	public function terminalNumFilter () {
		$response = DBTerminals::getFilteredTerminalsNum($this->search_value);
		echo json_encode($response);
	}

	public function terminalFilter () {
		$response = DBTerminals::getFilteredTerminalsForCharge($this->search_value);
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
		$response = DBSIM::getFilteredSIMForCharge($this->search_value);
		echo json_encode($response);
	}

	public function phoneFilter () {
		$response = DBPhones::getFilteredPhonesForCharge($this->search_value);
		echo json_encode($response);
	}

	public function deviceFilter () {
		$response = DBDevices::getFilteredDevicesForChangeLocation($this->search_value);
		echo json_encode($response);
	}
// for filter and pagination
	public function agentsFilter () {
		$filtered_data = DBAgents::getFilteredAgents('agent', $this->search_value, $this->skip);
		$this->ajaxResponse($filtered_data);
	}

	public function terminalsFilter () {
		$this->params = json_decode($_POST['params']);
		$sql_addon = $this->makeAdditionalConditionsStringSQL($this->params);
		$filtered_data = DBTerminals::getFilteredTerminals('terminal', $this->search_value, $this->skip, $sql_addon);
		$this->ajaxResponse($filtered_data);
	}

	public function devicesFilter () {
		$this->params = json_decode($_POST['params']);
		$sql_addon = $this->makeAdditionalConditionsStringSQL($this->params);
		$filtered_data = DBDevices::getFilteredDevices('device', $this->search_value, $this->skip, $sql_addon);
		$this->ajaxResponse($filtered_data);
	}

	public function simsFilter () {
		$this->params = json_decode($_POST['params']);
		$sql_addon = $this->makeAdditionalConditionsStringSQL($this->params);
		$filtered_data = DBSIM::getFilteredSIMs('sim', $this->search_value, $this->skip, $sql_addon);
		$this->ajaxResponse($filtered_data);
	}

	public function phonesFilter () {
		$filtered_data = DBPhones::getFilteredPhones('phone', $this->search_value, $this->skip);
		$this->ajaxResponse($filtered_data);
	}

	public function checkAgentByOffNum () {
		$response = DBAgents::getAgentByOffNum($this->search_value);
		echo json_encode($response);
	}

	// public function submitForm(){
	// 	$controller = $_POST['controller'];
	// 	$method = $_POST['method'];
	// 	$this->params = json_decode($_POST['params']);
	// 	// this is ajax == true
	// 	$this->params[] = true;
	// 	include_once "controller/" . $controller . ".php";
	// 	$controller = new $controller;
	// 	$response = call_user_func_array([$controller, $method], $this->params);
	// 	echo json_encode($response);
	// }

	public function ajaxResponse ($filtered_data) {
		$total_num = 0;
		if (isset($filtered_data[0]->total)) {
			$total_num = $filtered_data[0]->total;
		}
		$pagination_data = $this->preparePaginationLinks($total_num, $this->pg);
		$response = [$filtered_data, $pagination_data, $this->skip];
		echo json_encode($response);
	}
	public function makeAdditionalConditionsStringSQL ($params_obj) {
		$sql_addon = '';
		$table = '';
		foreach ($params_obj as $key => $param) {
			if ($param != '' && $key != 'active' && $key != 'sim_purpose') {
				switch ($key) {
					case 'type':
						$table = 'dt';
						break;

					case 'model':
						$table = 'm';
						break;

					case 'location':
						$table = 'l';
						break;

					case 'software_v':
						$table = 'swv';
						break;
					
					default:
						// do nothing here
						break;
				}
				$sql_addon .= ' and ' . "cast($table.id as text) = '$param' ";
			}
			if ($key == 'sim_purpose' && $param != '') {
				$sql_addon .= " and purpose = '$param' ";
			}
			if ($key == 'active' && $param == 1) {
				$sql_addon .= " and dwo.id is null ";
			} else if ($key == 'active' && $param == 2) {
				$sql_addon .= " and dwo.id is not null ";
			}
			
		}
		return $sql_addon;
	}
}