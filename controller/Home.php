<?php

class Home extends BaseController {
	public function index () {
		$this->data['title'] = 'Home';
		// $sql = 'select t.*, sc.network, sc.num, sc.iccid, d.sn as pda_sn, d.type as pda_type, d.nav_num as pda_nav_num, d1.sn as printer_sn, d1.type as printer_type, d1.nav_num as printer_nav_num, tn.terminal_num from terminals as t
		// join sim_cards as sc 
		// on t.sim_cards_id = sc.id 
		// join devices as d 
		// on t.pda_id = d.id 
		// join devices as d1
		// on t.printer_id = d1.id
		// join terminals_num as tn 
		// on tn.id = t.terminals_num_id 
		// ';
		// $this->data['devices'] = DB::queryAndFetchInObj($sql);
		$this->show_view('home');
	}
}