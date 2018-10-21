<?php

class Admin extends BaseController {
	public function index () {
		$this->data['title'] = 'Admin';
		$this->data['users'] = DBUsers::getAllUsers();
		$this->show_view('admin_page_1');
	}
	public function addNewUser ($username, $full_name, $password, $co_pass, $priviledge='user') {
		$req = DBUsers::addNewUser($username, $full_name, $password, $priviledge);
		if ($req) {
		// if (true) {
			Msg::createMessage("msg1", "Success.");
		} else {
			Msg::createMessage("msg1", "Unsuccess.");
		}
		header("Location: ".INCL_PATH."Admin/index");
	}
	public function editUserData($username, $full_name, $password, $priviledge, $user_id) {
		DBUsers::editUser($username, $full_name, $password, $priviledge, $user_id);
		header("Location: ".INCL_PATH."Admin/index");
	}
	public function removeUser($user_id) {
		DBUsers::removeUser($user_id);
		header("Location: ".INCL_PATH."Admin/index");
	}
	public function showPageNumTwo() {
		$this->data['title'] = 'Admin';
		$this->show_view('admin_page_2');
	}
	public function addNewWriter($first_name, $last_name) {
		$req = DBWriters::insertWriterIntoDB($first_name, $last_name);
		if ($req) {
		// if (true) {
			Msg::createMessage("msg1", "Success.");
		} else {
			Msg::createMessage("msg1", "Unsuccess.");
		}
		header("Location: ".INCL_PATH."Admin/panel");
	}
	public function addNewGenre($genre) {
		$req = DBGenres::insertGenreIntoDB($genre);
		if ($req) {
		// if (true) {
			Msg::createMessage("msg2", "Success.");
		} else {
			Msg::createMessage("msg2", "Unsuccess.");
		}
		header("Location: ".INCL_PATH."Admin/panel");
	}
}