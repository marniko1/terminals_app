class ShowProposals {
	constructor(){
		this.hideOptionDiv();
		this.unhideOptionDiv();
	}
	unhideOptionDiv(){
		jQuery('.proposal-input').on('keyup',function(e){
			var self = this;
			var input_text = false;
			var proposals_div = $(this).parents('.form-group').find('.proposals');
			var filter_value = $(this).val().trim();
			var ul = $(this).parents('.form-group').find('.proposals ul');
			var label_text = $(e.target).parents('.form-group').find('label').text();
			// var action = 'termminalsFilter';
			if (label_text == 'Terminal: ') {
				var fn = 'terminal';
			} else if (label_text == 'PDA: '){
				var fn = 'pda';
				// action = 'makeNewBook';
			} else if (label_text == 'Štampač: ') {
				var fn = 'printer';
			} else {
				var fn = 'sim';
			}
			
			setTimeout(function(){
				$.ajax({
					type: "POST",
					url: root_url + "AjaxCalls/index",
					data: "ajax_fn=" + fn + "Filter&search_value=" + filter_value,
					success: function(data){
						var response = JSON.parse(data);
						var div_html = '';
						if (label_text == 'Terminal: ') {
							$.each(response, function(i, val){
								div_html += `<li class="pl-1">${response[i].terminal_num}</li>`
							});
						} else if (label_text == 'PDA: ' || label_text == 'Štampač: ') {
							$.each(response, function(i, val){
								div_html += `<li class="pl-1">${response[i].sn}</li>`
							});
						} else {
							$.each(response, function(i, val){
								div_html += `<li class="pl-1">${response[i].iccid}</li>`
							});
						}
						// for validation make attr data-validate
						// ***************************************************
						$.each(response, function(key, value){
							if (value.writer == filter_value || value.title == filter_value || value.client == filter_value) {
								input_text = true;
							};
						});
						if (!input_text) {
							$(self).attr('data-validate', 'false');
						} else {
							$(self).attr('data-validate', 'true');
						}
						// ***************************************************
						$(ul).html(div_html);
						jQuery('.proposals li').on('click', function(e){
							var li_text = $(this).text();
							// removes <i>stock</i> from li text
							var text_to_remove = $(this).find('i').text();
							var text = li_text.replace(text_to_remove, '').trim();
							$(self).val(text);
							// set that input is valid
							$(self).attr('data-validate', 'true');
							$(this).parents('.mt-5').find('.proposals').addClass('d-none');
						});
					},
					error: function(XMLHttpRequest, textStatus, errorThrown) {
				     	alert("some error"+errorThrown);
				 	}
				});
			},1000);
			$(this).parents('.form-group').find('.proposals').removeClass('d-none');
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