<?php

class DBTerminals extends DB {
	public static function getAllTerminals() {
		$sql = "select t.*, sc.network, sc.num, sc.iccid, d.sn as pda_sn, 

		dt.title as pda_type, d.nav_num as pda_nav_num, d1.sn as printer_sn, 

		dt1.title as printer_type, d1.nav_num as printer_nav_num, tn.terminal_num, l.title as location from terminals as t 

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
		join devices_types as dt 
		on dt.id = d.device_type_id 
		join devices_types as dt1 
		on dt1.id = d1.device_type_id 
		where t.id not in (select terminal_id from terminals_disassembled) 
		order by tn.terminal_num
		";
		return self::queryAndFetchInObj($sql);
	}
	public static function getSingleTerminal($terminal_id){
		$sql = "select t.*, 
		sc.network, sc.num, sc.iccid, 
		d.sn as pda_sn, 

		dt.title as pda_type, d.nav_num as pda_nav_num, 
		d1.sn as printer_sn, 

		dt1.title as printer_type, d1.nav_num as printer_nav_num, 

		tn.terminal_num, 
		l.title as location, 
		concat(initcap(a.first_name), ' ', initcap(a.last_name)) as agent,
		concat(' ',initcap(a1.first_name), ' ', initcap(a1.last_name)) as current_agent, a1.id as current_agent_id, 
		to_char(tc.date, 'DD Mon YYYY') as charge_date, 
		to_char(tco.date, 'DD Mon YYYY') as charge_off_date, 

		td.id as disassembled 

		from terminals as t
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

		join devices_types as dt 
		on dt.id = d.device_type_id 
		join devices_types as dt1 
		on dt1.id = d1.device_type_id 

		left join terminals_disassembled as td 
		on t.id = td.terminal_id 

		left join terminals_charges as tc 
		on t.id = tc.terminal_id 
		left join terminals_charges_off as tco 
		on tc.id = tco.terminal_charge_id 
		left join agents as a 
		on tc.agent_id = a.id 
		left join agents as a1 
		on tc.agent_id = a1.id and tc.id not in (select terminal_charge_id from terminals_charges_off) 
		where t.id = $terminal_id order by current_agent desc";
		return self::queryAndFetchInObj($sql);
	}
	public static function getFilteredTerminalsNum ($cond) {
		$sql = "select tn.terminal_num as ajax_data from terminals_num as tn 
		left join terminals as t 
		on tn.id = t.terminals_num_id and t.id = (select max(id) from terminals where terminals_num_id = tn.id) 
		left join terminals_disassembled as td 
		on t.id = td.terminal_id
		where (t.terminals_num_id is null or td.id is not null)
		and cast(tn.terminal_num as character varying(5)) like '%$cond%' order by tn.terminal_num limit 6";
		return self::queryAndFetchInObj($sql);
	}
	public static function getFilteredTerminals ($cond) {
		$sql = "select tn.terminal_num as ajax_data from terminals_num as tn 
		left join terminals as t 
		on tn.id = t.terminals_num_id 
		left join terminals_charges as tc 
		on tc.terminal_id = t.id and tc.id not in (select terminal_charge_id from terminals_charges_off) 
		left join terminals_charges_off as tco 
		on tco.terminal_charge_id = tc.id 
		where t.terminals_num_id is not null 

		and t.id not in (select terminal_id from terminals_disassembled) 

		and case when tc.id is not null then tco.id is not null else true end 

		and cast(tn.terminal_num as character varying(5)) like '%$cond%' 
		order by tn.terminal_num limit 6";
		return self::queryAndFetchInObj($sql);
	}
	public static function addNewTerminal($terminal_num, $pda, $printer, $sim, $user_id){
		$sql = "select INSERT_NEW_TERMINAL($terminal_num, '$pda', '$printer', '$sim', $user_id)";
		// var_dump($sql);die;
		$req = self::executeSQL($sql);
		return $req;
	}
	public static function removeTerminal($id, $user_id){
		// var_dump($id);die;
		// $sql = "delete from terminals where id = $id";
		$sql = "insert into terminals_disassembled values (default, $id, default, $user_id)";
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