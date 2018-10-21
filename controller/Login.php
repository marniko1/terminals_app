<?php

class Login extends BaseController {
	public function index () {
		$this->data['title'] = 'Login';
		$this->show_view('login');
	}
	public function loginUser ($username, $password) {
		$checked_credentials = $this->checkCredentials($username, $password);
		if ($checked_credentials) {
			$_SESSION['logged'] = true;
			$_SESSION['user_id'] = $checked_credentials->id;
			$this->checkPriviledge($checked_credentials->title);
			header("Location: ".INCL_PATH);
		} else {
			Msg::createMessage("msg1", "Wrong user name or password.");
			header("Location: ".INCL_PATH);
		}
	}
	public function logoutUser () {
		unset($_SESSION['logged']);
		unset($_SESSION['priviledge']);
		header("Location: ".INCL_PATH);
	}
	public function checkCredentials ($username, $password) {
		$credentials = DBUsers::getCredentials($username)[0];
		if (isset($credentials)) {
			if ($credentials->username == $username && $credentials->password == $password) {
				return $credentials;
			} else {
				return false;
			}
		} else {
			return false;
		}
	}
	public function checkPriviledge ($priviledge) {
		if ($priviledge == 'admin') {
			$_SESSION['priviledge'] = 'admin';
		} else {
			$_SESSION['priviledge'] = 'user';
		}
	}
}