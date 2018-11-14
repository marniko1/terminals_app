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
		$params = func_get_args();
		self::$headers['From'] = $_SESSION['username'] . '@apextechnology.rs';
		switch ($params[0]) {
			// mail for charge
			case 'charge':
				self::$to = 'kontrola@apextechnology.rs, 
				dragana.lilic@apextechnology.rs, 
				jasmina.ciganovic@apextechnology.rs, 
				edin.becirovic@apextechnology.rs, 
				veljko.petrovic@apextechnology.com';

				self::$subject = "Zaduženje kontrolora - $params[1]";
				self::$message = "Zaduženje, $params[1] ($params[2])";
				if ($params[3] != 0) {
					self::$message .= ", PDA komplet $params[3]";
				}
				if ($params[5] != 0) {
					self::$message .= ", telefon $params[6] IMEI: $params[5]";
				}
				if ($params[4] != 0) {
					self::$message .= ", sim kartica $params[4]";
				}
				self::$message .= '.';
				self::$headers['Cc'] = 'vladimir.djukelic@apextechnology.rs';
				self::$headers['Bcc'] = 'marko.nikolic@apextechnology.rs';
				break;

			// mail for discharge
			case 'discharge':
				self::$to = 'kontrola@apextechnology.rs, 
				dragana.lilic@apextechnology.rs, 
				jasmina.ciganovic@apextechnology.rs, 
				edin.becirovic@apextechnology.rs, 
				veljko.petrovic@apextechnology.com';

				self::$subject = "Razduženje kontrolora - $params[1]";
				self::$message = "Razduženje, $params[1]($params[2])";
				if ($params[7] != 0) {
					self::$message .= ", PDA komplet $params[3]";
				}
				if ($params[9] != 0) {
					self::$message .= ", telefon $params[6] IMEI: $params[5]";
				}
				if ($params[8] != 0) {
					self::$message .= ", sim kartica $params[4]";
				}
				self::$message .= '.';
				if ($params[10] != '') {
					self::$message .= " " . $params[10];
				}
				self::$headers['Cc'] = 'vladimir.djukelic@apextechnology.rs';
				self::$headers['Bcc'] = 'marko.nikolic@apextechnology.rs';
				break;

			case 'terminal_switch':
				
				break;	
			
			default:
				die;
				break;
		}
	}
}