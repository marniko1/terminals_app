<?php

class Models {
	public function addNewModel ($model, $url, $purpose) {
		$req = DBModels::addNewModel($model, $purpose);
		if ($req) {
		// if (false) {
			Msg::createMessage("msg1", "Success.");
		} else {
			Msg::createMessage("msg1", "Unsuccess.");
		}
		header("Location: ".INCL_PATH.$url);
	}
}