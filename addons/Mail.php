<?php

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'PHPMailer/src/Exception.php';
require 'PHPMailer/src/PHPMailer.php';
require 'PHPMailer/src/SMTP.php';

class Mail {
	
	public static function sendMail () {
		$params = func_get_args();
		$mail = new PHPMailer(true);                              // Passing `true` enables exceptions
		try {
		    //Server settings
		    $mail->SMTPDebug = 2;                                 // Enable verbose debug output
		    $mail->isSMTP();                                      // Set mailer to use SMTP
		    $mail->Host = 'mail.busplus.rs';  // Specify main and backup SMTP servers
		    $mail->SMTPAuth = true;                               // Enable SMTP authentication
		    $mail->Username = 'marko.nikolic';                 // SMTP username
		    $mail->Password = '0106982710122';                           // SMTP password
		    $mail->SMTPSecure = 'tls';                            // Enable TLS encryption, `ssl` also accepted
		    $mail->Port = 25;                                    // TCP port to connect to 587



		    // $mail->setLanguage('sr', 'PHPMailer/language/');
		    $mail->CharSet = 'UTF-8';



		    //Recipients
		    $mail->setFrom($_SESSION['username'] . '@apextechnology.rs');
		    // $mail->addAddress('marko.nikolic@apextechnology.rs');     // Add a recipient
		    // $mail->addAddress('ellen@example.com');               // Name is optional
		    // $mail->addReplyTo('info@example.com', 'Information');
		    // $mail->addCC('cc@example.com');
		    $mail->addBCC('marko.nikolic@apextechnology.rs');

		    //Content
		    $mail->isHTML(true);

		    switch ($params[0]) {
			// mail for charge
			case 'charge':
				$recipients = array(
									'kontrola@apextechnology.rs', 
									'dragana.lilic@apextechnology.rs', 
									'jasmina.ciganovic@apextechnology.rs', 
									'edin.becirovic@apextechnology.rs', 
									'veljko.petrovic@apextechnology.rs'
								);
				foreach ($recipients as $recipient) {
					$mail->addAddress($recipient);
				}
				$mail->addCC('vladimir.djukelic@apextechnology.rs');

				$mail->Subject = "Zaduženje kontrolora - $params[1]";
				$mail->Body = "Zaduženje, $params[1] ($params[2])";
				if ($params[3] != 0) {
					$mail->Body .= ", PDA komplet $params[3]";
				}
				if ($params[5] != 0) {
					$mail->Body .= ", telefon $params[6] IMEI: $params[5]";
				}
				if ($params[4] != 0) {
					$mail->Body .= ", sim kartica $params[4]";
				}
				$mail->Body .= '.';
				break;

			// mail for discharge
			case 'discharge':
				$recipients = array(
									'kontrola@apextechnology.rs', 
									'dragana.lilic@apextechnology.rs', 
									'jasmina.ciganovic@apextechnology.rs', 
									'edin.becirovic@apextechnology.rs', 
									'veljko.petrovic@apextechnology.rs'
								);
				// $mail->addAddress('marko.nikolic@apextechnology.rs');
				foreach ($recipients as $recipient) {
					$mail->addAddress($recipient);
				}
				$mail->addCC('vladimir.djukelic@apextechnology.rs');
				$mail->Subject = "Razduženje kontrolora - $params[1]";
				$mail->Body = "Razduženje, $params[1]($params[2])";
				if ($params[7] != 0) {
					$mail->Body .= ", PDA komplet $params[3]";
				}
				if ($params[9] != 0) {
					$mail->Body .= ", telefon $params[6] IMEI: $params[5]";
				}
				if ($params[8] != 0) {
					$mail->Body .= ", sim kartica $params[4]";
				}
				$mail->Body .= '.';
				if ($params[10] != '') {
					$mail->Body .= " " . $params[10];
				}
				break;

			case 'terminal_switch':
				
				break;	
			
			default:
				die;
				break;
		}

		    $mail->send();
		    echo 'Message has been sent';
		} catch (Exception $e) {
		    echo 'Message could not be sent. Mailer Error: ', $mail->ErrorInfo;
		}
	}
}