<?php

class Devices extends BaseController {
	public function __construct () {
		$this->data['title'] = 'Devices';
	}
	public function index ($pg = 0) {
		$skip = 0;
		if ($pg !== 0) {
			$pg = substr($pg, 1);
			$skip = $pg*PG_RESULTS-PG_RESULTS;
		}
		$this->data['devices'] = DBDevices::getAllDevices($skip);
		$total_devices_num = $this->data['devices'][0]->total;
		$this->data['pagination_links'] = $this->preparePaginationLinks($total_devices_num, $pg);
		$this->show_view('devices');
	}
	public function showSingleDevice ($id) {
		$this->data['device'] = DBDevices::getSingleDevice($id);
		$this->show_view('device');
	}
}