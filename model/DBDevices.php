<?php

class DBDevices extends DB {
	public static function getAllDevices ($skip) {
		$sql = "select d.*, l.title as location, 
		(select count(*) from devices) as total 
		from devices as d 
		join devices_locations as dl 
		on d.id = dl.device_id 
		join locations as l 
		on dl.location_id = l.id 
		order by d.sn limit " .PG_RESULTS. "offset $skip";
		return self::queryAndFetchInObj($sql);
	}
	public static function getSingleDevice ($id) {
		$sql = "select d.*, l.title as location 
		from devices as d 
		join devices_locations as dl 
		on d.id = dl.device_id 
		join locations as l 
		on dl.location_id = l.id 
		where d.id = $id";
		return self::queryAndFetchInObj($sql);
	}
	public static function getFilteredPDA ($cond) {
		$sql = "select d.sn  as ajax_data from devices as d 
		left join terminals as t 
		on d.id = t.pda_id or  d.id = t.printer_id 
		left join devices_locations as dl 
		on d.id = dl.device_id 
		left join locations as l 
		on dl.location_id = l.id 
		where t.pda_id is null and t.printer_id is null and l.title = 'magacin' and d.type = 'pda' and d.writed_off = 0 and d.sn like '%$cond%' order by d.id limit 6";
		return self::queryAndFetchInObj($sql);
	}
	public static function getFilteredPrinter ($cond) {
		$sql = "select d.sn  as ajax_data from devices as d 
		left join terminals as t 
		on d.id = t.pda_id or  d.id = t.printer_id 
		left join devices_locations as dl 
		on d.id = dl.device_id 
		left join locations as l 
		on dl.location_id = l.id 
		where t.pda_id is null and t.printer_id is null and l.title = 'magacin' and d.type = 'printer' and d.writed_off = 0 and d.sn like '%$cond%' order by d.id limit 6";
		return self::queryAndFetchInObj($sql);
	}
	public static function getFilteredDevices ($cond_name, $cond, $skip) {
		$sql = "select d.*, l.title as location, 
		(select count(*) from devices where 
		lower(cast(sn as character varying(30))) like lower('%$cond%') 
		or lower(nav_num) like lower('%$cond%')) 
		as total 
		from devices as d 
		join devices_locations as dl 
		on d.id = dl.device_id 
		join locations as l 
		on dl.location_id = l.id 
		where lower(cast(d.sn as character varying(30))) like lower('%$cond%') 
		or lower(d.nav_num) like lower('%$cond%') 
		order by d.sn limit " .PG_RESULTS. "offset $skip";
		return self::queryAndFetchInObj($sql);
	}
}