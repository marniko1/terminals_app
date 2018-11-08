<?php

class DBUsers extends DB {
	public static function getCredentials($username) {
		$sql = "select u.*, p.title from users as u 
		join priviledges as p 
		on p.id = u.priviledge_id 
		where u.username = '$username' and u.active = 1";
		return self::queryAndFetchInObj($sql);
	}
	public static function getAllUsers() {
		$sql = "select u.*, p.title as priviledge from users as u 
		join priviledges as p 
		on p.id = u.priviledge_id 
		where u.active = 1 
		";
		$res = self::executeSQL($sql);
		return self::queryAndFetchInObj($sql);
	}
	public static function addNewUser($username, $password, $priviledge){
		$sql = "insert into users values (default, '$username', '$password', '$priviledge')";
		$req = self::executeSQL($sql);
		return $req;
	}
	// public static function editUser($username, $full_name, $password, $priviledge, $user_id){
	// 	$sql = "update users set username = '$username', full_name = '$full_name', password = '$password', priviledge = '$priviledge' where id = $user_id";
	// 	self::executeSQL($sql);
	// }
	public static function removeUser($user_id){
		$sql = "update users set active = 0 where id = $user_id";
		return self::executeSQL($sql);
	}
}