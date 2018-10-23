<?php

class Mail {
	public static function sendMail ($type, $agent, $off_num, $terminal, $sim = 0, $phone) {
		$to = 'marko.nikolic@apextechnology.rs, veljko.petrovic@apextechnology.com';
		$subject = 'test';
		$message = ucfirst($type) . ", $agent ($off_num), PDA komplet $terminal, telefon LG IMEI:$phone, sim kartica $phone";
		$headers = array(
					'From' => 'marko.nikolic@apextechnology.rs',
					'Content-Type' => 'text/html; charset=UTF-8'
					);
		mail($to, $subject, $message, $headers);
	}
}

// 'Zaduženje, Jelena Petrović (98520), PDA komplet 44137, telefon LG IMEI:358330-04-123892-3, sim kartica 2193'
// 'Razduženje, Miodrag Lazarević (98515), PDA komplet 44108, telefon Alcatel One Touch IMEI:356788068923515, sim kartica 2358'