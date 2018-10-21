<?php

class Error404 extends BaseController {
	public function index () {
		$this->data['title'] = 'Error';
		$this->show_view('error404');
	}
}