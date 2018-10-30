<?php

class DBSIM extends DB {
	public static function getAllSIM ($skip) {
		$sql = "select *, (select count(*) from sim_cards) as total from sim_cards order by num limit ".PG_RESULTS. "offset $skip";
		return self::queryAndFetchInObj($sql);
	}
	public static function getFilteredSIMForPDA ($cond) {
		$sql = "select sc.iccid as ajax_data from sim_cards as sc  
		left join terminals as t 
		on sc.id = t.sim_cards_id 
		where t.sim_cards_id is null and sc.purpose = 'pda' and sc.iccid like '%$cond%' order by sc.id limit 6";
		return self::queryAndFetchInObj($sql);
	}
	public static function getFilteredSIM ($cond) {
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
	public static function getFilteredSIMs ($cond_name, $cond, $skip) {
		$sql = "select id, concat('+', network, '/', num), iccid, purpose, 
		(select count(*) from sim_cards where iccid like '%cond%' 
		or cast(num as character varying(7)) like '%$cond%') as total 
		from sim_cards 
		where iccid like '%cond%' or cast(num as character varying(7)) like '%$cond%'
		order by num limit ".PG_RESULTS. "offset $skip";
		return self::queryAndFetchInObj($sql);
	}
}