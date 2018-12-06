<?php

class DBSIM extends DB {
	public static function getAllSIM ($skip) {
		$sql = "select *, (select count(*) from sim_cards) as total from sim_cards order by num limit ".PG_RESULTS. "offset $skip";
		return self::queryAndFetchInObj($sql);
	}
	public static function getSingleSIM ($sim_id) {
		$sql = "select * from sim_cards where id = $sim_id";
		return self::queryAndFetchInObj($sql);
	}
	public static function getFilteredSIMForPDA ($cond) {
		$sql = "select sc.iccid as ajax_data from sim_cards as sc  
		left join terminals as t 
		on sc.id = t.sim_cards_id 
		left join terminals_disassembled as td 
		on td.terminal_id = t.id 
		where (t.sim_cards_id is null or td.id is not null) and sc.purpose = 'pda' and sc.iccid like '%$cond%' order by sc.id limit 6";
		return self::queryAndFetchInObj($sql);
	}
	public static function getFilteredSIMForCharge ($cond) {
		$sql = "select substr(cast(sc.num as text), 4) as ajax_data from sim_cards as sc 
		left join sim_cards_charges as scc 
		on scc.sim_id = sc.id and scc.id = (select max(id) from sim_cards_charges where sim_id = scc.sim_id)
		left join sim_cards_charges_off as scco 
		on scco.sim_card_charge_id = scc.id 
		where purpose = 'kontrola' 

		and case when scc.id is not null then scco.id is not null else true end  

		and substr(cast(sc.num as text), 4) like '%$cond%' 
		order by sc.id limit 6";
		return self::queryAndFetchInObj($sql);
	}
	public static function getFilteredSIMs ($cond_name, $cond, $skip, $sql_addon) {
		$sql = "select id, concat('+', network, '/', num), iccid, purpose, 
		(select count(*) from sim_cards where (cast(iccid as text) like '%$cond%' 
		or cast(num as text) like '%$cond%') " . $sql_addon . ") as total 
		from sim_cards 
		where (cast(iccid as text) like '%$cond%' or cast(num as character varying(7)) like '%$cond%') " . $sql_addon . "
		order by num limit ".PG_RESULTS. " offset $skip";
		return self::queryAndFetchInObj($sql);
	}
	public static function addNewSIM ($network, $num, $iccid, $purpose) {
		$sql = "insert into sim_cards values (default, $network, $num, '$iccid', '$purpose')";
		$req = self::executeSQL($sql);
		return $req;
	}
}