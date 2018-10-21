<?php

class DBDevices extends DB {
	public static function getAllDevices () {
		$sql = "select d.*, l.title as location from devices as d 
		join devices_locations as dl 
		on d.id = dl.device_id 
		join locations as l 
		on dl.location_id = l.id 
		order by d.sn";
		return self::queryAndFetchInObj($sql);
	}
	public static function getFilteredPDA ($cond) {
		$sql = "select d.sn from devices as d 
		left join terminals as t 
		on d.id = t.pda_id or  d.id = t.printer_id 
		left join devices_locations as dl 
		on d.id = dl.device_id 
		left join locations as l 
		on dl.location_id = l.id 
		where t.pda_id is null and t.printer_id is null and l.title = 'magacin' and d.type = 'pda' and d.writed_off = 0 and d.sn like '%$cond%' order by d.id limit 6";
		return self::queryAndFetchInObj($sql);
	}
	public static function getFilteredPrinters ($cond) {
		$sql = "select d.sn from devices as d 
		left join terminals as t 
		on d.id = t.pda_id or  d.id = t.printer_id 
		left join devices_locations as dl 
		on d.id = dl.device_id 
		left join locations as l 
		on dl.location_id = l.id 
		where t.pda_id is null and t.printer_id is null and l.title = 'magacin' and d.type = 'printer' and d.writed_off = 0 and d.sn like '%$cond%' order by d.id limit 6";
		return self::queryAndFetchInObj($sql);
	}
}