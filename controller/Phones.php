<?php

class Phones extends BaseController {
	public function index () {
		$this->data['title'] = 'Phones';
		$this->data['phones'] = DBPhones::getAllPhones();
		$this->show_view('phones');
	}
}