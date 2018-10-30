class Discharge {
	constructor () {
		this.disabler();
	}
	disabler () {
		if ($('#terminal').text() == '') {
			$("input[type='checkbox'][name='terminal']").attr("disabled", true);
		}
		if ($('#sim').text() == '') {
			$("input[type='checkbox'][name='sim']").attr("disabled", true);
		}
		if ($('#phone').text() == '') {
			$("input[type='checkbox'][name='phone']").attr("disabled", true);
		}
		if ($('#terminal').text() == '' && $('#sim').text() == '' && $('#phone').text() == '') {
			$("#discharge_form").addClass("d-none");
			$("input[type='submit']").attr("disabled", true);
		}
	}
}