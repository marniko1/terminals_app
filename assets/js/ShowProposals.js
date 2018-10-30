class ShowProposals {
	constructor(){
		this.hideOptionDiv();
		this.unhideOptionDiv();
	}
	unhideOptionDiv(){
		jQuery('.proposal-input').on('keyup',function(e){
			if ($(this).val() != '') {
				var self = this;
				var input_text = false;
				var proposals_div = $(this).parents('.form-group').find('.proposals');
				var filter_value = $(this).val().trim();
				var ul = $(this).parents('.form-group').find('.proposals ul');
				var label_text = $(e.target).parents('.form-group').find('label').text();
				if (label_text == 'Terminal Br.: ') {
					var fn = 'terminalNum';
				} else if (label_text == 'PDA: '){
					var fn = 'pda';
				} else if (label_text == 'Štampač: ') {
					var fn = 'printer';
				} else if (label_text == 'pdaSIM: ') {
					var fn = 'pdaSim';
				} else if (label_text == 'Terminal: ') {
					var fn = 'terminal';
				} else if (label_text == 'SIM: ') {
					var fn = 'sim';
				} else if (label_text == 'Telefon IMEI: ') {
					var fn = 'phone';
					$('#model, #model_hidden').val('');
				}
				console.log(fn);
				
				setTimeout(function(){
					$.ajax({
						type: "POST",
						url: root_url + "AjaxCalls/index",
						data: "ajax_fn=" + fn + "Filter&search_value=" + filter_value,
						success: function(data){
							var response = JSON.parse(data);
							console.log(response);
							var div_html = '';
							$.each(response, function(i, val){
								// adding model if proposals are for phone
								if (fn == 'phone') {
									div_html += `<li class="pl-1" data-model="${response[i].model}">${response[i].ajax_data}</li>`;
								} else {
									div_html += `<li class="pl-1">${response[i].ajax_data}</li>`;
								}
							});
							// if (label_text == 'Broj terminala: ') {
							// 	$.each(response, function(i, val){
							// 		div_html += `<li class="pl-1">${response[i].terminal_num}</li>`
							// 	});
							// } else if (label_text == 'PDA: ' || label_text == 'Štampač: ') {
							// 	$.each(response, function(i, val){
							// 		div_html += `<li class="pl-1">${response[i].sn}</li>`
							// 	});
							// } else if (label_text == 'SIM: ') {
							// 	$.each(response, function(i, val){
							// 		div_html += `<li class="pl-1">${response[i].iccid}</li>`
							// 	});
							// }

							// for validation make attr data-validate
							// ***************************************************
							// $.each(response, function(key, value){
							// 	if (value.writer == filter_value || value.title == filter_value || value.client == filter_value) {
							// 		input_text = true;
							// 	};
							// });
							// if (!input_text) {
							// 	$(self).attr('data-validate', 'false');
							// } else {
							// 	$(self).attr('data-validate', 'true');
							// }
							// ***************************************************


							if (response.length != 0) {
								$(self).parents('.form-group').find('.proposals').removeClass('d-none');
							} else {
								$(self).parents('.form-group').find('.proposals').addClass('d-none');
							}
							
							$(ul).html(div_html);
							jQuery('.proposals li').on('click', function(e){
								var text = $(this).text();
								$(self).val(text);
								// set that input is valid
								// $(self).attr('data-validate', 'true');
								$(this).parents('.mt-5').find('.proposals').addClass('d-none');
								// adding model if proposals are for phone
								if (fn == 'phone') {
									$('#model, #model_hidden').val($(this).data('model'));
									// $('#model_hidden').val($(this).data('model'));
								}
							});
						},
						error: function(XMLHttpRequest, textStatus, errorThrown) {
					     	alert("some error"+errorThrown);
					 	}
					});
				},1000);
			} else {
				$('.proposals').addClass('d-none');
			}
		});
	}
	// hideOptionDiv() {
	// 	jQuery('.proposal-input').focusout(function(e){
	// 		setTimeout(function(){
	// 			$(e.target).parents('.mt-5').find('.proposals').addClass('d-none');
	// 		}, 300);
	// 	});
	// }
	hideOptionDiv() {
		jQuery('html').on('click', function(e){
				var div = $(e.target).parents('.form-group').find('.proposals');
				if (div.length !== 0) {
					$(e.target).parents('.mt-5').find('.proposals').not(div).addClass('d-none');
				} else {
					$('.proposals').addClass('d-none');
				}
		});
	}
	takeLiValueInInput() {
		jQuery('.proposal li').on('click', function(e){
			var li_text = $(e.target).text();
			console.log(li_text);
		});
	}
}