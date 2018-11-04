<?php

class DBLocations extends DB {
	public static function getAllLocations () {
		$sql = "select * from locations";
		return self::queryAndFetchInObj($sql);
	}
}