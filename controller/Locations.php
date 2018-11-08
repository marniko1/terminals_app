<?php

class Locations extends BaseController {
	public function addNewLocation ($location) {
		$req = DBLocations::addNewLocation($location);
		if ($req) {
		// if (false) {
			Msg::createMessage("msg1", "Success.");
		} else {
			Msg::createMessage("msg1", "Unsuccess.");
		}
		header("Location: ".INCL_PATH."Devices/panel");
	}
}