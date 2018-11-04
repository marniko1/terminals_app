<?php

class DBModels extends DB {
	public static function getAllModels () {
		$sql = "select * from models";
		return self::queryAndFetchInObj($sql);
	}
	public static function addNewPhoneModel () {
		
	}
}