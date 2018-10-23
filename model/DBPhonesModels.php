<?php

class DBPhonesModels extends DB {
	public static function getAllPhoneModels () {
		$sql = "select * from cellphones_models";
		return self::queryAndFetchInObj($sql);
	}
	public static function addNewPhoneModel () {
		
	}
}