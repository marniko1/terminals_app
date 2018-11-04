<?php

class DBTypes extends DB {
	public static function getAllTypes () {
		$sql = "select * from devices_types";
		return self::queryAndFetchInObj($sql);
	}
}