<?php

class DBPhones extends DB {
	public static function getAllPhones () {
		$sql = "select cp.*, cpm.title as model from cellphones as cp
			join cellphones_models as cpm 
			on cpm.id = cp.model_id";
		return self::queryAndFetchInObj($sql);
	}
	public static function addNewPhone ($model_id, $imei) {
		$sql = "insert into cellphones values (default, $model_id, $imei)";
		return self::executeSQL($sql);
	}
}