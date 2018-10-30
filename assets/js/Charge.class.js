class Charge {
	constructor () {
		this.offNumCecker();
	}
	offNumCecker() {
		$('#off_num').on('change keyup paste', function(){
			if ($('#off_num').val().length == 5) {
				$('#agent').val('');
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
							$('#terminal, #sim, #imei, #submit').attr('disabled', false);
						} else {
							$('#agent').attr('disabled', false);
							$('#agent').on('keyup', function(){
								if ($('#agent').val().match(/[a-zA-Z]{3,}\s[a-zA-Z]{1,}/)) {
									$('#terminal, #sim, #imei, #submit').attr('disabled', false);
								} else {
									$('#terminal, #sim, #imei, #submit').attr('disabled', true);
								}
							});
						}
					},
					error: function(XMLHttpRequest, textStatus, errorThrown) {
				     	alert("some error"+errorThrown);
				 	}
				});
			} else {
				$('#agent, #terminal, #sim, #imei, #submit').attr('disabled', true);
				$('#agent').val('');
				$('#agent').parent().find("input[type='hidden']").remove();
			}
		});
	}
	agentNameCecker() {
		
	}
}