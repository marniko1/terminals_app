<?php

class Devices extends BaseController {
	public function __construct () {
		$this->data['title'] = 'Devices';
	}
	public function index ($pg = 1) {
		if ($pg !== 1) {
			$pg = substr($pg, 1);
			$this->skip = $pg*PG_RESULTS-PG_RESULTS;
		}
		$this->data['devices'] = DBDevices::getAllDevices($this->skip);
		$this->data['models'] = DBModels::getAllDevicesModels();
		$this->data['types'] = DBTypes::getAllTypes();
		$this->data['locations'] = DBLocations::getAllLocations();
		$this->data['software_v'] = DBSoftwareVersions::getAllSoftwareV();
		$total_devices_num = $this->data['devices'][0]->total;
		$this->data['pagination_links'] = $this->preparePaginationLinks($total_devices_num, $pg);
		$this->show_view('devices');
	}
	public function showPageNumTwo() {
		$this->data['locations'] = DBLocations::getAllLocations();
		$this->show_view('devices_locations');
	}
	public function showSingleDevice ($id) {
		$this->data['device'] = DBDevices::getSingleDevice($id);
		$this->show_view('device');
	}
	public function changeDeviceLocation ($location_id, $device_id) {
		$req = DBDevices::changeDeviceLocation($location_id, $device_id);
		if ($req) {
		// if (false) {
			Msg::createMessage("msg1", "Success.");
		} else {
			Msg::createMessage("msg1", "Unsuccess.");
		}
		header("Location: ".INCL_PATH."Devices/panel");
	}
}