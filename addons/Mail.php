<?php

class Mail {
	public static $to = '';
	public static $subject = '';
	public static $message = '';
	public static $headers = array('Content-Type' => 'text/html; charset=UTF-8');

	public static function sendMail () {

		$params = func_get_args();
		forward_static_call_array(array('self', "prepareMessage"), $params);

		mail(self::$to, self::$subject, self::$message, self::$headers);
	}
	public static function prepareMessage () {
		// var_dump(func_get_args());die;
		$params = func_get_args();
		$comment = '';
		$dot = '';
		// if ($params[3] == 0 or $params[4] == 0 or $params[5] == 0) {
		// 	$dot = '.';
		// }
		switch ($params[0]) {
			// mail for charge
			case 'charge':
				if ($params[3] == 0 or $params[4] == 0 or $params[5] == 0) {
					$comment = ' Nije zadužen ';
					$dot = '.';
				}
				self::$to = 'marko.nikolic@apextechnology.rs, veljko.petrovic@apextechnology.com';
				self::$subject = "Zaduženje kontrolora - $params[1]";
				self::$message = "Zaduženje, $params[1]($params[2])";
				if ($params[3] != 0) {
					self::$message .= ", PDA komplet $params[3]";
				} else {
					$comment .= 'PDA';
				}
				if ($params[5] != 0) {
					self::$message .= ", telefon $params[6] IMEI: $params[5]";
				} else {
					if ($params[3] == 0) {
						$comment .= ', telefon';
					} else {
						$comment .= 'telefon';
					}
				}
				if ($params[4] != 0) {
					self::$message .= ", sim kartica $params[4]";
				} else {
					if ($params[5] == 0 or $params[3] == 0) {
						$comment .= ', sim';
					} else {
						$comment .= 'sim';
					}
				}
				self::$message .= '.';
				$comment .= $dot;
				self::$message .= $comment;
				self::$headers['From'] = 'marko.nikolic@apextechnology.rs';
				break;

			// mail for discharge
			case 'discharge':
				if ($params[7] == 0 or $params[8] == 0 or $params[9] == 0) {
					$comment = ' Nije razdužen ';
					$dot = '.';
				}
				self::$to = 'marko.nikolic@apextechnology.rs, veljko.petrovic@apextechnology.com';
				self::$subject = "Razduženje kontrolora - $params[1]";
				self::$message = "Razduženje, $params[1]($params[2])";
				if ($params[7] != 0) {
					self::$message .= ", PDA komplet $params[3]";
				} else {
					$comment .= 'PDA';
				}
				if ($params[9] != 0) {
					self::$message .= ", telefon $params[6] IMEI: $params[5]";
				} else {
					if ($params[7] == 0) {
						$comment .= ', telefon';
					} else {
						$comment .= 'telefon';
					}
				}
				if ($params[8] != 0) {
					self::$message .= ", sim kartica $params[4]";
				} else {
					if ($params[8] == 0 or $params[7] == 0) {
						$comment .= ', sim';
					} else {
						$comment .= 'sim';
					}
				}
				self::$message .= '.';
				$comment .= $dot;
				self::$message .= $comment;
				if ($params[10] != '') {
					self::$message .= " " . $params[10];
				}
				self::$headers['From'] = 'marko.nikolic@apextechnology.rs';
				break;

			case 'terminal_switch':
				
				break;	
			
			default:
				die;
				break;
		}
	}
}