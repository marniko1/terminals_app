<?php

class DBSIM extends DB {
	public static function getAllSIM () {
		$sql = "select * from sim_cards";
		return self::queryAndFetchInObj($sql);
	}
	public static function getFilteredSIM ($cond) {
		$sql = "select sc.iccid from sim_cards as sc  
		left join terminals as t 
		on sc.id = t.sim_cards_id 
		where t.sim_cards_id is null and sc.purpose = 'pda' and sc.iccid like '%$cond%' order by sc.id limit 6";
		return self::queryAndFetchInObj($sql);
	}
}