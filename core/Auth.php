<?php

class Auth {

	
	public static function logged() {
		if (isset($_SESSION['logged'])) {
			return true;
		}
		return false;
	}

	public static function admin() {
		if ($_SESSION['priviledge'] == 'admin') {
			return true;
		}
		return false;
	}
}