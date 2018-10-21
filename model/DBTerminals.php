<?php

class DBTerminals extends DB {
	public static function getAllTerminals() {
		$sql = "select t.*, sc.network, sc.num, sc.iccid, d.sn as pda_sn, d.type as pda_type, d.nav_num as pda_nav_num, d1.sn as printer_sn, d1.type as printer_type, d1.nav_num as printer_nav_num, tn.terminal_num, l.title as location from terminals as t
		join sim_cards as sc 
		on t.sim_cards_id = sc.id 
		join devices as d 
		on t.pda_id = d.id 
		join devices as d1
		on t.printer_id = d1.id 
		join devices_locations as dl 
		on d.id = dl.device_id 
		join locations as l 
		on dl.location_id = l.id 
		join terminals_num as tn 
		on tn.id = t.terminals_num_id 
		";
		return self::queryAndFetchInObj($sql);
	}
	public static function getSingleTerminal($terminal_id){
		$sql = "select t.*, sc.network, sc.num, sc.iccid, d.sn as pda_sn, d.type as pda_type, d.nav_num as pda_nav_num, d1.sn as printer_sn, d1.type as printer_type, d1.nav_num as printer_nav_num, tn.terminal_num, l.title as location from terminals as t
		join sim_cards as sc 
		on t.sim_cards_id = sc.id 
		join devices as d 
		on t.pda_id = d.id 
		join devices as d1
		on t.printer_id = d1.id 
		join devices_locations as dl 
		on d.id = dl.device_id 
		join locations as l 
		on dl.location_id = l.id 
		join terminals_num as tn 
		on tn.id = t.terminals_num_id 
		where t.id = $terminal_id";
		return self::queryAndFetchInObj($sql);
	}
	public static function getFilteredTerminalsNum ($cond) {
		$sql = "select tn.terminal_num from terminals_num as tn 
		left join terminals as t 
		on tn.id = t.terminals_num_id 
		where t.terminals_num_id is null and cast(tn.terminal_num as character varying(5)) like '%$cond%' order by tn.terminal_num limit 6";
		return self::queryAndFetchInObj($sql);
	}
	public static function addNewTerminal($terminal_num, $pda, $printer, $sim){
		$sql = "select INSERT_NEW_TERMINAL($terminal_num, '$pda', '$printer', '$sim')";
		$req = self::executeSQL($sql);
		return $req;
	}
	public static function removeTerminal($id){
		// var_dump($id);die;
		$sql = "delete from terminals where id = $id";
		$req = self::executeSQL($sql);
		return $req;
	}
	// public static function editUser($username, $full_name, $password, $priviledge, $user_id){
	// 	$sql = "update users set username = '$username', full_name = '$full_name', password = '$password', priviledge = '$priviledge' where id = $user_id";
	// 	self::executeSQL($sql);
	// }
	// public static function removeUser($user_id){
	// 	$sql = "delete from users where id = $user_id";
	// 	return self::executeSQL($sql);
	// }
}