<?php

class DBPhones extends DB {
	public static function getAllPhones () {
		$sql = "select cp.*, m.title as model from cellphones as cp
			join models as m 
			on m.id = cp.model_id";
		return self::queryAndFetchInObj($sql);
	}
	public static function addNewPhone ($model_id, $imei) {
		$sql = "insert into cellphones values (default, $model_id, $imei)";
		return self::executeSQL($sql);
	}
	public static function getFilteredPhones ($cond) {
		$sql = "select cp.imei as ajax_data, m.title as model from cellphones as cp 
			join models as m 
			on m.id = cp.model_id
			left join cellphones_charges as cpc 
			on cpc.cellphone_id = cp.id and cpc.id = (select max(id) from cellphones_charges where cellphone_id = cpc.cellphone_id)
			left join cellphones_charges_off as cpco 
			on cpco.cellphone_charge_id = cpc.id 

			
			where cp.imei like '%$cond%'
			
			and case when cpc.id is not null then cpco.id is not null else true end 

			order by cp.id limit 6";
		return self::queryAndFetchInObj($sql);
	}
}