class Charge {
	constructor () {
		this.offNumCecker();
	}
	offNumCecker() {
		$('#off_num').on('change keyup paste', function(){
			if ($('#off_num').val().length == 5) {
				$('#agent, #terminal, #sim, #imei, #model').val('');
				$.ajax({
					type: "POST",
					url: root_url + "AjaxCalls/index",
					data: "ajax_fn=checkAgentByOffNum"  + "&search_value=" + $('#off_num').val(),
					success: function(data){
						var response = JSON.parse(data);
						if (response.length != 0) {
							$('#agent').val(response[0].agent);
							$('#agent').attr('disabled', true);
							$('#agent').parent().find("input[type='hidden']").remove();
							$('#agent').parent().append(`<input type="hidden" name="agent" value="${response[0].agent}">`);
							if (response[0].terminal_num == null) {
								$('#terminal, #submit_btn').attr('disabled', false);
							} else {
								$('#terminal').val(response[0].terminal_num);
							}
							if (response[0].imei == null) {
								$('#imei, #submit_btn').attr('disabled', false);
							} else {
								$('#imei').val(response[0].imei);
								$('#model').val(response[0].phone_model);
							}
							if (response[0].num == null) {
								$('#sim, #submit_btn').attr('disabled', false);
							} else {
								var num = response[0].num.toString();
								num = num.substring(-1,4);
								$('#sim').val(response[0].num.toString().substring(-1,4));
							}
						} else {
							$('#agent').attr('disabled', false);
							$('#agent').on('keyup', function(){
								if ($('#agent').val().match(/[a-zA-Z]{3,}\s[a-zA-Z]{1,}/)) {
									$('#terminal, #sim, #imei, #submit_btn').attr('disabled', false);
								} else {
									$('#terminal, #sim, #imei, #submit_btn').attr('disabled', true);
								}
							});
						}
					},
					error: function(XMLHttpRequest, textStatus, errorThrown) {
				     	alert("some error"+errorThrown);
				 	}
				});
			} else {
				$('#agent, #terminal, #sim, #imei, #submit_btn').attr('disabled', true);
				$('#agent, #terminal, #sim, #imei, #model').val('');
				$('#agent').parent().find("input[type='hidden']").remove();
			}
		});
	}
	agentNameCecker() {
		
	}
}