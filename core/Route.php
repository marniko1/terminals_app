<?php

class Route {
	public static $controller;
	public static $method;
	public static $params = [];


	// post method of class Route
	public static function post($url, $action, $req=[]) {
		self::$params = $_POST;
		$path = self::findServerPath();
		$url_arr = self::prepareURL($url);
		$path_arr = self::prepareServerURLPath();
		if ($path_arr[0] != $url_arr[0] || count($path_arr) != count($url_arr)) {
			return;
		} else {
			$action = explode('@', $action);
			self::$controller = $action[0];
			self::$method = $action[1];
			include_once 'controller/'.self::$controller.'.php';
			self::$controller = new self::$controller;

			if (ltrim($url, '/') == $path) {
				call_user_func_array([self::$controller, self::$method], self::$params);
				exit;
			} else if (!empty($req)) {
				self::$params = self::collectParams($url_arr, $path_arr);
				foreach ($req as $key => $value) {
					if (!preg_match($value, self::$params[$key])) {
						return;
					}
				}
				call_user_func_array([self::$controller, self::$method], self::$params);
				exit;
			} else {
				return;
			}
		}
	}


	// get method of class  Route
	public static function get($url, $action, $req=[]) {
		$path = self::findServerPath();
		$url_arr = self::prepareURL($url);
		$path_arr = self::prepareServerURLPath();
		if ($path_arr[0] != $url_arr[0] || count($path_arr) != count($url_arr)) {
			return;
		} else {

			if (ltrim($url, '/') == $path) {
				self::$params = [];
			} else if (!empty($req)) {
				self::$params = self::collectParams($url_arr, $path_arr);
				foreach ($req as $key => $value) {
					if (!preg_match($value, self::$params[$key])) {
						return;
					}
				}
			} else {
				return;
			}
			$action = explode('@', $action);
			self::$controller = $action[0];
			self::$method = $action[1];
			include_once 'controller/'.self::$controller.'.php';
			self::$controller = new self::$controller;
		}
		call_user_func_array([self::$controller, self::$method], self::$params);
		exit;
	}


	// redirect method of class Route
	public static function redirect($action) {
		$action = explode('@', $action);
		self::$controller = $action[0];
		self::$method = $action[1];
		include_once 'controller/'.self::$controller.'.php';
		self::$controller = new self::$controller;
		call_user_func(array(self::$controller, self::$method));
	}


	// auxiliaries below
	public static function prepareURL ($url) {
		$url = ltrim($url, '/');
		return explode('/', $url);
	}

	public static function findServerPath () {
		return str_replace(INCL_PATH, '', $_SERVER['REQUEST_URI']);
	}

	public static function prepareServerURLPath () {
		$path = self::findServerPath();
		return $path_arr = explode('/', $path);
	}

	public static function collectParams($url_arr, $path_arr) {
		foreach ($url_arr as $key => $value) {
			if (preg_match('/^{+(.*)+}$/', $value)) {
				self::$params[] = $path_arr[$key];
			}
		}
		return self::$params;
	}

	public static function checkReq() {

	}
	public static function checkURL (){

	}
}