<?php
require ROOT_DIR.'config/database_conn.php';

class DB {

	private static $data = [];
	private static $conn;
	private static $instance;

	private static function getInstance(){
		if(!isset(self::$conn)){
			self::$instance = new DB();
		}
		return self::$conn;
	}

	private function __construct(){
		try {
		    self::$conn = new PDO(DSN, DBUSER, DBPASS);
		} catch (PDOException $e) {
		    echo 'Connection failed: ' . $e->getMessage();
		}
	}
	public static function executeSQL($sql) {
		$conn = self::getInstance();
		$res = $conn->query($sql, PDO::FETCH_OBJ);
		return $res;
	}
	public static function queryAndFetchInObj($sql) {
		$res = self::executeSQL($sql);
		foreach ($res as $row) {
			self::$data[] = $row;
		}
		return self::$data;
	}
}