<?php

class bookUnaviableException extends Exception {
	private $data = [];

	public function __construct($data) {
        $this->data = $data;
        // parent::__construct($message);
    }

    public function getData() {
        return $this->data;
    }
}