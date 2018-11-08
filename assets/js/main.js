window.onload = function() {
	// console.log(window.location.origin + window.location.pathname);
	// console.log(window.location.pathname);
	// turn off autocomplete sugestion from browser
	$('input').attr('autocomplete', 'off');
	// makes ajax for pagination and filter
	var controller = window.location.href.split('/').reverse()[1];
	if (controller.match(/(\d+)/)) {
		controller = window.location.href.split('/').reverse()[2].slice(0, -1);
	}
	var filter = $('#filter');
	var pagination_links = $(".pagination li a");
	new FilterAndPagination(filter, pagination_links, controller);
    // *************************************************************************************************
	// forms submit validation
    if (window.location.pathname == '/terminals_app/Terminals/panel' 
    	|| window.location.pathname == '/terminals_app/Charges/index'
    	|| window.location.pathname == '/terminals_app/SIMs/panel'
    	|| window.location.pathname == '/terminals_app/Phones/panel'
    	|| window.location.pathname == '/terminals_app/Admin/index'
    	|| window.location.pathname == '/terminals_app/Devices/panel'
    	) {
    	console.log('terminal')
    	// form validation
    	var frmvalidator = new Validator($('form'));

    	// add validation rules on fields
    	// make new charge fields validation rules
    	frmvalidator.addValidation('terminal', ['proposalValidation']);
    	frmvalidator.addValidation('sim_for_charge', ['proposalValidation']);
    	frmvalidator.addValidation('imei', ['proposalValidation']);

    	// add new_terminal fields validation rules
    	frmvalidator.addValidation('terminal_num', ['req', 'proposalValidation']);
    	frmvalidator.addValidation('pda', ['req', 'proposalValidation']);
    	frmvalidator.addValidation('printer', ['req', 'proposalValidation']);
    	frmvalidator.addValidation('pda_sim_for_new_terminal', ['req', 'proposalValidation']);

    	// add new_sim fields validation rules
    	frmvalidator.addValidation('network', ['req', 'minLength=2', 'maxLength=2']);
    	frmvalidator.addValidation('number', ['req', 'minLength=6', 'maxLength=7']);
    	frmvalidator.addValidation('iccid', ['req']);
    	frmvalidator.addValidation('purpose', ['req']);

    	// add new_phone fields validation rules
    	frmvalidator.addValidation('new_phone_imei', ['req']);
    	frmvalidator.addValidation('new_model', ['req']);

    	// add new_user fields validation rules
    	frmvalidator.addValidation('username', ['req', 'minLength=3', 'maxLength=20']);
    	frmvalidator.addValidation('password', ['req', 'passConfirm=#co_password']);
    	frmvalidator.addValidation('co_password', ['req', 'passConfirm=#password']);

		new FormSubmit(frmvalidator);
		
		
    	new ShowProposals();
	}
	// ***********************************************************************************************
	// if page url is single agent view prepare discharge
	var url = window.location.origin + window.location.pathname;
	var url_part = url.replace(root_url, '').split('/');
	if (url_part[0] == 'Agents' && url_part[1].match(/^\d+$/)) {
		new Discharge();
	}
	// ***********************************************************************************************
	// if page url is charge view prepare charge form
	var url = window.location.origin + window.location.pathname;
	var url_part = url.replace(root_url, '').split('/');
	if (url_part[0] == 'Charges'  && url_part[1] == 'index') {
		new Charge();
	}
	// ***********************************************************************************************
	// if page url is single book view or single client view or single writer view, only then prepare for edit button
	var url = window.location.origin + window.location.pathname;
	var url_part = url.replace(root_url, '').split('/');
	if ((url_part[0] == 'Clients' || url_part[0] == 'Books' || url_part[0] == 'Writers') && url_part[1].match(/^\d+$/)) {
		new Edit(url_part[0]);
	}
	// **********************************************************************************************
	// for single terminal page
	if (url_part[0] == 'Terminals' && url_part[1].match(/^\d+$/)) {
		if ($('span#location_span').text() == 'magacin') {
			$('input[name="remove"]').attr('disabled', false);
		}
	}
}