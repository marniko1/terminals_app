<?php

class DBSoftwareVersions extends DB {
	public static function getAllSoftwareV () {
		$sql = "select * from software_v";
		return self::queryAndFetchInObj($sql);
	}
}