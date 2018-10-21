<?php

class Msg {
	public static function createMessage($key, $msg) {
		$_SESSION['msg'][$key] = $msg;
	}

	public static function getMessage() {
		if (isset($_SESSION['msg'])) {
			return $_SESSION['msg'];
		}
	}

	// public static function getMessageKey() {
	// 	if (isset($_SESSION['msg'])) {
	// 		return array_keys($_SESSION['msg']);
	// 	}
	// }

	public static function unsetMsgSession() {
		unset($_SESSION['msg']);
	}
}