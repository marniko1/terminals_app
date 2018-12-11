<?php

class DBAgents extends DB {
	public static function getAllAgents ($skip) {
		$sql = "select *, 
		a.id as single_agent_id, 
		substr(cast(sc.num as text), 4) as agent_sim_num, 
		concat(initcap(a.first_name), ' ', initcap(a.last_name)) as agent, 

		(select count(*) from agents) as total 
		from agents as a 

		left join terminals_charges as tc 
		on a.id = tc.agent_id and tc.id not in (select terminal_charge_id from terminals_charges_off) 
		left join terminals as t 
		on t.id = tc.terminal_id 
		left join terminals_num as tn
		on tn.id = t.terminals_num_id 

		left join sim_cards_charges as scc 
		on a.id = scc.agent_id and scc.id not in (select sim_card_charge_id from sim_cards_charges_off) 
		left join sim_cards as sc 
		on sc.id = scc.sim_id 

		where a.active = 1 

		order by agent limit ".PG_RESULTS. " offset $skip";
		return self::queryAndFetchInObj($sql);
	}
	public static function getSingleAgent ($id) {
		$sql = "select a.*, 
		concat(initcap(a.first_name), ' ', initcap(a.last_name)) as agent, 
		tn.terminal_num, 
		d.sn as pda_sn, d.nav_num as pda_nav_num, 
		d1.sn as printer_sn, d1.nav_num as printer_nav_num, 
		sc.num, sc.iccid, 
		sc1.num as pda_sim, sc1.iccid as pda_sim_iccid, 
		m.title as phone_model, 
		cp.imei, 
		tc.id as terminal_charge, 
		to_char(tc.date, 'DD Mon YYYY') as terminal_charge_date 


		from agents as a 
		
		left join terminals_charges as tc 
		on tc.agent_id = a.id and tc.id not in (select terminal_charge_id from terminals_charges_off) 
		left join terminals_charges_off as tco 
		on tco.terminal_charge_id = tc.id 

		left join terminals as t 
		on t.id = tc.terminal_id 

		left join terminals_num as tn 
		on t.terminals_num_id = tn.id 

		left join terminals as t1 
		on t1.id = (select max(id) from terminals where terminals_num_id = tn.id) 
		left join devices as d 
		on d.id = t1.pda_id 
		left join devices as d1 
		on d1.id = t1.printer_id 

		left join cellphones_charges as cpc 
		on cpc.agent_id = a.id and cpc.id not in (select cellphone_charge_id from cellphones_charges_off) 
		left join cellphones_charges_off as cpco 
		on cpco.cellphone_charge_id = cpc.id
		left join cellphones as cp 
		on cp.id = cpc.cellphone_id 
		left join models as m 
		on cp.model_id = m.id 

		left join sim_cards_charges as scc 
		on scc.agent_id = a.id and scc.id not in (select sim_card_charge_id from sim_cards_charges_off) 
		left join sim_cards_charges_off as scco 
		on scco.sim_card_charge_id = scc.id 
		left join sim_cards as sc 
		on sc.id = scc.sim_id 
		left join sim_cards as sc1 
		on t.sim_cards_id = sc1.id

		where a.id = $id";
		return self::queryAndFetchInObj($sql);
	}
	public static function getFilteredAgents ($cond_name, $cond, $skip) {
		$sql = "select a.id, concat(initcap(a.first_name), ' ', initcap(a.last_name)) as agent, a.off_num, 

		substr(cast(sc.num as text), 4) as agent_sim_num, 
		tn.terminal_num, 

		(select count(*) from agents where concat(first_name, ' ', last_name) like '%$cond%' or cast(off_num as character varying(5)) like '%$cond%') as total 
		from agents as a 

		left join terminals_charges as tc 
		on a.id = tc.agent_id and tc.id not in (select terminal_charge_id from terminals_charges_off) 
		left join terminals as t 
		on t.id = tc.terminal_id 
		left join terminals_num as tn
		on tn.id = t.terminals_num_id 

		left join sim_cards_charges as scc 
		on a.id = scc.agent_id and scc.id not in (select sim_card_charge_id from sim_cards_charges_off) 
		left join sim_cards as sc 
		on sc.id = scc.sim_id 

		where a.active = 1 and (lower(concat(first_name, ' ', last_name)) like lower('%$cond%')  or lower(cast(off_num as text)) like lower('%$cond%')) 
		order by $cond_name 
		limit ".PG_RESULTS. " offset $skip";
		return self::queryAndFetchInObj($sql);
	}
	public static function getAgentByOffNum ($off_num) {
		$sql = "select concat(initcap(a.first_name), ' ', initcap(a.last_name)) as agent, tn.terminal_num, cp.imei, m.title as phone_model, substr(cast(sc.num as text), 4) as num from agents as a 

		left join terminals_charges as tc 
		on tc.agent_id = a.id and tc.id not in (select terminal_charge_id from terminals_charges_off) 
		left join terminals as t 
		on t.id = tc.terminal_id 		 
		left join terminals_num as tn 
		on t.terminals_num_id = tn.id 

		left join cellphones_charges as cpc 
		on cpc.agent_id = a.id and cpc.id not in (select cellphone_charge_id from cellphones_charges_off) 
		left join cellphones as cp 
		on cp.id = cpc.cellphone_id 
		left join models as m 
		on cp.model_id = m.id 

		left join sim_cards_charges as scc 
		on scc.agent_id = a.id and scc.id not in (select sim_card_charge_id from sim_cards_charges_off) 
		left join sim_cards as sc 
		on sc.id = scc.sim_id 

		where off_num = $off_num";
		return self::queryAndFetchInObj($sql);
	}
	// public static function getAgentByOffNum ($off_num) {
	// 	$sql = "select concat(initcap(first_name), ' ', initcap(last_name)) as agent from agents where off_num = $off_num";
	// 	return self::queryAndFetchInObj($sql);
	// }
}

// select tc.id, d.sn, tn.terminal_num from agents as a 

// left join terminals_charges as tc 
// on tc.agent_id = a.id and tc.id not in (select terminal_charge_id from terminals_charges_off)

// left join terminals as t 
// on t.id = tc.terminal_id 

// left join terminals_num as tn 
// on tn.id = t.terminals_num_id 

// left join devices as d 
// on d.id = t.pda_id 

// where a.last_name = 'stanković' and a.first_name = 'aleksandar'