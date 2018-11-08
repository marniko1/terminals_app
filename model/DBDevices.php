<?php

class DBDevices extends DB {
	public static function getAllDevices ($skip) {
		$sql = "select d.*, l.title as location, 
		m.title as model, 
		dt.title as type, 
		swv.software as sw_ver, 
		dwo.id as writed_off, 
		(select count(*) from devices) as total 
		from devices as d 
		join devices_locations as dl 
		on d.id = dl.device_id 
		join locations as l 
		on dl.location_id = l.id 
		join models as m 
		on m.id = d.model_id 
		join devices_types as dt 
		on dt.id = d.device_type_id 
		left join devices_softwares as dsw 
		on dsw.device_id = d.id and dsw.id = (select max(id) from devices_softwares where device_id = d.id) 
		left join software_v as swv 
		on swv.id = dsw.software_v_id
		left join devices_writes_off as dwo 
		on dwo.device_id = d.id 
		order by d.sn limit " .PG_RESULTS. "offset $skip";
		return self::queryAndFetchInObj($sql);
	}
	public static function getSingleDevice ($id) {
		$sql = "select d.*, 
		l.title as location,
		m.title as model, 
		dt.title as type, 
		swv.software as sw_ver, 
		dwo.id as writed_off 

		from devices as d 
		join devices_locations as dl 
		on d.id = dl.device_id 
		join locations as l 
		on dl.location_id = l.id 

		join models as m 
		on m.id = d.model_id 
		join devices_types as dt 
		on dt.id = d.device_type_id 
		left join devices_softwares as dsw 
		on dsw.device_id = d.id and dsw.id = (select max(id) from devices_softwares where device_id = d.id) 
		left join software_v as swv 
		on swv.id = dsw.software_v_id
		left join devices_writes_off as dwo 
		on dwo.device_id = d.id 

		where d.id = $id";
		return self::queryAndFetchInObj($sql);
	}
	public static function getFilteredPDA ($cond) {
		$sql = "select d.sn  as ajax_data from devices as d 
		join devices_types as dt 
		on dt.id = d.device_type_id 
		left join terminals as t 
		on d.id = t.pda_id 
		left join devices_locations as dl 
		on d.id = dl.device_id 
		left join locations as l 
		on dl.location_id = l.id 
		left join devices_writes_off as dwo 
		on dwo.device_id = d.id 
		left join terminals_disassembled as td 
		on td.terminal_id = t.id 
		where (t.pda_id is null or td.id is not null) and l.title = 'magacin' and dt.title = 'pda' and dwo.id is null and lower(cast(d.sn as character varying(30))) like lower('%$cond%') order by d.id limit 6";
		return self::queryAndFetchInObj($sql);
	}
	public static function getFilteredPrinter ($cond) {
		$sql = "select d.sn  as ajax_data from devices as d 
		join devices_types as dt 
		on dt.id = d.device_type_id 
		left join terminals as t 
		on d.id = t.pda_id or  d.id = t.printer_id 
		left join devices_locations as dl 
		on d.id = dl.device_id 
		left join locations as l 
		on dl.location_id = l.id 
		left join devices_writes_off as dwo 
		on dwo.device_id = d.id 
		left join terminals_disassembled as td 
		on td.terminal_id = t.id 
		where (t.printer_id is null or td.id is not null) and l.title = 'magacin' and dt.title = 'printer' and dwo.id is null and lower(cast(d.sn as character varying(30))) like lower('%$cond%') order by d.id limit 6";
		return self::queryAndFetchInObj($sql);
	}
	public static function getFilteredDevices ($cond_name, $cond, $skip, $sql_addon) {
		// ini_set("xdebug.var_display_max_children", -1);
		// ini_set("xdebug.var_display_max_data", -1);
		// ini_set("xdebug.var_display_max_depth", -1);
		$sql = "select d.sn, d.nav_num, d.id, 
		m.title as model, 
		dt.title as type, 
		swv.software as sw_ver, 
		dwo.id as writed_off, 
		l.title as location, 

		(select count(*) from devices as d 

		join devices_locations as dl 
		on d.id = dl.device_id 
		join locations as l 
		on dl.location_id = l.id 
		
		join devices_types as dt 
		on dt.id = d.device_type_id 
		join models as m 
		on m.id = d.model_id 
		left join devices_softwares as dsw 
		on dsw.device_id = d.id and dsw.id = (select max(id) from devices_softwares where device_id = d.id) 
		left join devices_writes_off as dwo 
		on dwo.device_id = d.id 

		where 
		(lower(cast(d.sn as text)) like lower('%$cond%') 
		or lower(d.nav_num) like lower('%$cond%')) " . $sql_addon . ") 
		as total 



		from devices as d 


		join devices_locations as dl 
		on d.id = dl.device_id 
		join locations as l 
		on dl.location_id = l.id 
		join models as m 
		on m.id = d.model_id 
		join devices_types as dt 
		on dt.id = d.device_type_id 
		left join devices_softwares as dsw 
		on dsw.device_id = d.id and dsw.id = (select max(id) from devices_softwares where device_id = d.id) 
		left join software_v as swv 
		on swv.id = dsw.software_v_id
		left join devices_writes_off as dwo 
		on dwo.device_id = d.id 
		where (lower(cast(d.sn as character varying(30))) like lower('%$cond%') 
		or lower(d.nav_num) like lower('%$cond%')) " . 
		$sql_addon
		. "	order by d.sn limit " .PG_RESULTS. " offset $skip";
		return self::queryAndFetchInObj($sql);
	}

	public static function getFilteredDevicesForChangeLocation ($cond) {
		$sql = "select id, sn as ajax_data from devices
		where lower(cast(sn as text)) like lower('%$cond%') 
		or lower(nav_num) like lower('%$cond%') 
		limit 6
		";
		return self::queryAndFetchInObj($sql);
	}

	public static function changeDeviceLocation ($location_id, $device_id) {
		$sql = "update devices_locations set location_id = $location_id where device_id = $device_id";
		return self::executeSQL($sql);
	}
}