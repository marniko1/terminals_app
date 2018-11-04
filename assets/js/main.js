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
	// stylize forms on home page
    if (window.location.pathname == '/terminals_app/Terminals/panel' || window.location.pathname == '/terminals_app/Charges/index') {

    	// form validation
    	var frmvalidator = new Validator($('div.col-6.form-wrapper form'));

    	// add validation rules on fields
    	// make new charge fields validation rules
    	frmvalidator.addValidation('terminal', ['proposalValidation']);
    	frmvalidator.addValidation('sim', ['proposalValidation']);
    	frmvalidator.addValidation('imei', ['proposalValidation']);
    	// frmvalidator.addValidation('email', ['req', 'email']);
    	// add new_book fields validation rules
    	// frmvalidator.addValidation('title', ['req']);
    	// frmvalidator.addValidation('writer', ['req', 'proposalValidation']);
    	// frmvalidator.addValidation('stock', ['req', 'moreThenNull']);
    	// frmvalidator.addValidation("genre[]", ['checkedOne']);
    	// frmvalidator.addValidation('description', ['req']);
    	// add new_rental fields validation rules
    	// frmvalidator.addValidation('client', ['req', 'proposalValidation']);
    	// frmvalidator.addValidation('title1', ['req', 'proposalValidation']);
    	// frmvalidator.addValidation('title2', ['proposalValidation']);
    	// frmvalidator.addValidation('title3', ['proposalValidation']);
    	// frmvalidator.addValidation('title4', ['proposalValidation']);
    	// frmvalidator.addValidation('title5', ['proposalValidation']);

		new FormSubmit(frmvalidator);
		
		// var first_input = document.querySelector('input');
		// first_input.focus();
		// jQuery('input, textarea').on('click', function(){
		// 	// $('input, textarea').not($(this).parents('div.form-wrapper').find('input, textarea')).css('box-shadow', 'initial').css('border', '1px solid #ced4da');
		// 	$('input, textarea, .checkbox-wrapper').not($(this).parents('div.form-wrapper').find('input, textarea, .checkbox-wrapper')).removeClass('err-border');
		// 	// $('.checkbox-wrapper').not($(this).parents('form').find('.checkbox-wrapper')).css('box-shadow', 'none').css('border', 'none');
		// 	$('span.val').not($(this).parents('div.form-wrapper').find('span.val')).remove();
		// 	$('.checkbox-holder').addClass('d-none');
		// 	$('div.form-wrapper').removeClass('col-6').addClass('col-3 opacity-5');
		// 	$('div.form-wrapper .msg-span').contents().remove();
		// 	$('div.form-wrapper .msg-span').removeClass('text-danger text-success');
		// 	$('div.form-wrapper input').not(':input[type=submit], :input[type=checkbox]').not($(this).parents('div.form-wrapper').find('input')).val('');
		// 	$('div.form-wrapper input.btn').prop('disabled', true);
		// 	$('div.border').removeClass('border-primary').addClass('border-secondary');
		// 	$(this).parents('div.form-wrapper').removeClass('col-3 opacity-5').addClass('col-6');
		// 	$(this).parents('div.border').removeClass('border-secondary').addClass('border-primary');
		// 	$(this).parents('div.form-wrapper').find('input.btn').removeAttr('disabled');
		// 	$(this).parents('div.form-wrapper.col-6').find('.checkbox-holder').removeClass('d-none');
		// });
    	// add new rental proposals filters
    	new ShowProposals();
		// style for msg span
		var msg_span = $('div.form-wrapper span');
		if (msg_span) {
			if (msg_span.text() == "Success.") {
				msg_span.addClass('text-success');
			} else if (msg_span.text() == "Unsuccess.") {
				msg_span.addClass('text-danger');
			}
		}
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
	// ***********************************************************************************************
	// if page is Admin
	if (url_part[0] == 'Admin') {
		new Edit(url_part[0]);
		var frmvalidator = new Validator($('form'));

		frmvalidator.addValidation('username', ['req', 'minLength=3', 'maxLength=20']);
    	frmvalidator.addValidation('full_name', ['req', 'minLength=6', 'maxLength=40']);
    	frmvalidator.addValidation('password', ['req', 'passConfirm=#co_password']);
    	frmvalidator.addValidation('co_password', ['req', 'passConfirm=#password']);

    	frmvalidator.addValidation('first_name', ['req', 'minLength=3', 'maxLength=20']);
    	frmvalidator.addValidation('last_name', ['req', 'minLength=3', 'maxLength=20']);
    	
    	frmvalidator.addValidation('genre_title', ['req', 'minLength=3', 'maxLength=20']);

    	jQuery('.submit').on('click', function(e){
    		e.preventDefault();
    		if (frmvalidator.validation($(this).parents('form'))) {
    			$(this).parents('form').submit();
    		}
    	});
    	var msg_span = $('div.form-wrapper span');
    	if (msg_span.text() == "Success.") {
			msg_span.addClass('text-success');
		} else if (msg_span.text() == "Unsuccess.") {
			msg_span.addClass('text-danger');
		}
	}
	// **********************************************************************************************
	// for single terminal page
	if (url_part[0] == 'Terminals' && url_part[1].match(/^\d+$/)) {
		if ($('span#location_span').text() == 'magacin') {
			$('input[name="remove"]').attr('disabled', false);
		}
	}
}