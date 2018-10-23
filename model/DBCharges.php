<?php
class DBCharges extends DB {
	public static function makeNewCharge ($agent, $off_num, $terminal, $sim, $imei, $user_id) {
		$sql = "select make_new_charge('$agent', $off_num, $terminal, $sim, '$imei', $user_id)";
		return self::executeSQL($sql);
	}
	public static function makeDischarge ($agent_id, $terminal, $sim, $phone, $inactiv, $user_id) {
		$sql = "select discharge($agent_id, $terminal, $sim, $phone, $inactiv, $user_id)";
		return self::executeSQL($sql);
	}
}