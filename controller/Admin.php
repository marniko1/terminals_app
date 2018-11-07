<?php

class Admin extends BaseController {
	public function __construct () {
		$this->data['title'] = 'Admin';
	}
	public function index () {
		$this->data['users'] = DBUsers::getAllUsers();
		$this->show_view('admin_page');
	}
	public function addNewUser ($username, $password, $co_pass, $priviledge=1) {
		$req = DBUsers::addNewUser($username, $password, $priviledge);
		if ($req) {
		// if (true) {
			Msg::createMessage("msg1", "Success.");
		} else {
			Msg::createMessage("msg1", "Unsuccess.");
		}
		header("Location: ".INCL_PATH."Admin/index");
	}
	// public function editUserData($username, $full_name, $password, $priviledge, $user_id) {
	// 	DBUsers::editUser($username, $full_name, $password, $priviledge, $user_id);
	// 	header("Location: ".INCL_PATH."Admin/index");
	// }
	public function removeUser($user_id) {
		DBUsers::removeUser($user_id);
		header("Location: ".INCL_PATH."Admin/index");
	}
	// public function showPageNumTwo() {
	// 	$this->data['title'] = 'Admin';
	// 	$this->show_view('admin_page_2');
	// }
}