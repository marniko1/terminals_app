<?php


if (Auth::logged()) {
	
	Route::get('/', 'Home@index');

	Route::get('/Terminals/index', 'Terminals@index');
	Route::get('/Terminals/panel', 'Terminals@showPageNumTwo');
	Route::get('/Terminals/{id}', 'Terminals@showSingleTerminal', $req = ['/^\d+$/']);
	// Route::get('/Rentals/{page}', 'Rentals@index', $req = ['/^p\d+$/']);
	Route::post('/Terminals/addNewTerminal', 'Terminals@addNewTerminal');
	Route::post('/Terminals/removeTerminal', 'Terminals@removeTerminal');

	Route::get('/Devices/index', 'Devices@index');

	Route::get('/SIM/index', 'SIM@index');

	Route::get('/Phones/index', 'Phones@index');

	Route::get('/Agents/index', 'Agents@index');
	Route::get('/Agents/{id}', 'Agents@showSingleAgent', $req = ['/^\d+$/']);

	Route::get('/Charges/index', 'Charges@index');
	Route::get('/Charges/panel', 'Charges@showPageNumTwo');
	Route::post('/Charges/makeCharge', 'Charges@makeCharge');
	Route::post('/Charges/discharge', 'Charges@discharge');

	Route::get('/Service/index', 'Service@index');

	// if (Auth::admin()) {
	// 	Route::get('/Admin/index', 'Admin@index');
	// 	Route::get('/Admin/panel', 'Admin@showPageNumTwo');
	// 	Route::post('/Admin/addNewUser', 'Admin@addNewUser');
	// 	Route::post('/Admin/editUserData', 'Admin@editUserData');
	// 	Route::post('/Admin/removeUser', 'Admin@removeUser');
	// 	Route::post('/Admin/addNewWriter', 'Admin@addNewWriter');
	// 	Route::post('/Admin/addNewGenre', 'Admin@addNewGenre');
	// }

	Route::get('/AjaxCalls/index', 'AjaxCalls@index');

	Route::post('/Login/logoutUser', 'Login@logoutUser');

	Route::redirect('Error404@index');
} else {
	Route::post('/Login/loginUser', 'Login@loginUser');
	Route::redirect('Login@index');
}