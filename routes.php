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
	Route::get('/Devices/{id}', 'Devices@showSingleDevice', $req = ['/^\d+$/']);

	Route::get('/SIMs/index', 'SIMs@index');
	Route::get('/SIMs/panel', 'SIMs@showAddNewSimPage');
	Route::get('/SIMs/{id}', 'SIMs@showSingleSIM', $req = ['/^\d+$/']);
	Route::post('/SIMs/addNewSIM', 'SIMs@addNewSIM');

	Route::get('/Phones/index', 'Phones@index');
	Route::get('/Phones/panel', 'Phones@showPageNumTwo');
	Route::post('/Phones/addNewPhone', 'Phones@addNewPhone');

	Route::get('/Agents/index', 'Agents@index');
	Route::get('/Agents/{id}', 'Agents@showSingleAgent', $req = ['/^\d+$/']);
	Route::get('/Agents/{page}', 'Agents@index', $req = ['/^p\d+$/']);

	Route::get('/Charges/index', 'Charges@index');
	Route::get('/Charges/panel', 'Charges@showPageNumTwo');
	Route::post('/Charges/makeCharge', 'Charges@makeCharge');
	Route::post('/Charges/discharge', 'Charges@discharge');

	Route::post('/Models/addNewModel', 'Models@addNewModel');

	Route::get('/Service/index', 'Service@index');

	if (Auth::admin()) {
		Route::get('/Admin/index', 'Admin@index');
		// Route::get('/Admin/panel', 'Admin@showPageNumTwo');
		Route::post('/Admin/addNewUser', 'Admin@addNewUser');
		// Route::post('/Admin/editUserData', 'Admin@editUserData');
		Route::post('/Admin/removeUser', 'Admin@removeUser');
	}

	Route::get('/AjaxCalls/index', 'AjaxCalls@index');

	Route::post('/Login/logoutUser', 'Login@logoutUser');

	Route::redirect('Error404@index');
} else {
	Route::post('/Login/loginUser', 'Login@loginUser');
	Route::redirect('Login@index');
}