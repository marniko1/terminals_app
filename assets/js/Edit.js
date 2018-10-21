class Edit {
	constructor(page){
		this.frmvalidator = new Validator($('form.edit_form'));
		this.tdToInput();
		this.isValid;
		this.page = page;
		if (this.page == 'Admin') {
			this.hiddenInputEnable();
		} else {
			this.setRemoveAlert();
		}
	}
	tdToInput(){
		var self = this;
		jQuery('.edit').on('click', function(){
			if (self.page == 'Admin') {
				var tds = $(this).parents('tr').find('td');
			} else {
				var tds = $(this).parents('form').find('table.main tbody tr td');
			}
			$('.edit, .remove').not(this).attr('disabled', true);
			if (self.page == 'Admin') {
				$(this).parents('tr').find('[type="hidden"]').attr('disabled', false);
			}
			var data_to_store = {};
			$.each(tds, function(key, td){
				var text = $(td).text();
				data_to_store[$(td).data('name')] = text;
				if (text.length > 40) {
					$(td).html('<div  class="position-relative form-group"><textarea rows="3" style="width: 100%" name="'+$(td).data('name')+'" id="'+$(td).data('name')+'" class="form-control">'+text+'</textarea></div>');
				} else if (self.page == 'Books' && $(td).data('name') == 'genre') {
					// making checkboxes for book genre edit
					var old_genres = data_to_store['genre'];
					old_genres = old_genres.split(',');
					var html = '<div class="checkbox-wrapper rounded position-relative" ><div class="genres-scroll">';
					$.ajax({
						type: "POST",
						url: root_url + "AjaxCalls/index",
						data: "ajax_fn=getAllGenres",
						success: function(data){
							var response = JSON.parse(data);
							$.each(response, function(ke, value){
								html += '<div class="position-relative form-check form-check-inline mr-0 pr-0 col-12"><input type="checkbox" value="'+ value.id +'" name="genre[]"  id="checkbox'+(ke+1)+'"><label for="checkbox'+(ke+1)+'" class="mb-0">'+value.title+'</label></div>';
							});
							html += '</div></div>';
							$(td).html(html);
							var checkboxes_for_edit = $('input:checkbox');
							// checking checkboxes for old genres
							$.each(checkboxes_for_edit, function(k, checkbox){
								$.each(old_genres, function(kk, genre){
									if ($(checkbox).next('label').text() == genre.trim()) {
										$(checkbox).attr('checked', true);
									}
								});
							});
							// put eventListener onchange to control max 3 checked chekboxes
				    		var checked = $('input:checked');
				    		if (checked.length >= 3) {
				    			$(checkboxes_for_edit).not(checked).attr('disabled', true);
				    		}
							$(checkboxes_for_edit).change(function(){
								checked = $('input:checked');
					    		if (checked.length >= 3) {
					    			$(checkboxes_for_edit).not(checked).attr('disabled', true);
					    		} else {
					    			$(checkboxes_for_edit).not(checked).attr('disabled', false);
					    		}
					    	});
						},
						error: function(XMLHttpRequest, textStatus, errorThrown) {
					     	alert("some error"+errorThrown);
					 	}
					});
				} else if (self.page == 'Books' && $(td).data('name') == 'writer') {
					$(td).html('<div class="position-relative form-group"><input type="text" value="'+text+'" style="width: 100%" name="'+$(td).data('name')+'"  id="'+$(td).data('name')+'" class="form-control proposal-input"><div class="proposals d-none"><ul class="mb-0 pl-0"></ul></div></div>');
					new ShowProposals();
				} else {
					$(td).html('<div class="position-relative form-group"><input type="text" value="'+text+'" style="width: 100%" name="'+$(td).data('name')+'"  id="'+$(td).data('name')+'" class="form-control"></div>');
				}
			});
			localStorage.removeItem('for_cancel');
			localStorage.setItem('for_cancel', JSON.stringify(data_to_store));
			var path = self.makeFormActionPath($(this).parents('form'), 'edit');
			$(this).parents('form').attr('action', root_url + path);
			if (self.page == 'Admin') {
				$(this).parent('div.btn-holder').html('<input type="submit" name="save" value="Save" class="btn edit btn-success btn-sm"><input type="button" name="cancel" value="Cancel" class="btn ml-2 btn-danger btn-sm">');
			} else {
				$(this).parent('div.btn-holder').html('<input type="submit" name="save" value="Save" class="btn edit btn-success"><input type="button" name="cancel" value="Cancel" class="btn ml-2 btn-danger">');
			}
			// make validation rules, depending on wich page are you
			if (self.page == 'Clients') {
				self.frmvalidator.addValidation('client', ['req', 'minLength=6', 'maxLength=40']);
		    	self.frmvalidator.addValidation('email', ['req', 'email']);
		    	self.frmvalidator.addValidation('address', ['req', 'minLength=3', 'maxLength=20']);
		    	self.frmvalidator.addValidation('stock', ['req', 'positiveNum']);
			} else if (self.page == 'Books') {
				self.frmvalidator.addValidation('title', ['req']);
		    	self.frmvalidator.addValidation('description', ['req']);
		    	self.frmvalidator.addValidation('genre[]', ['checkedOne']);
		    	self.frmvalidator.addValidation('writer', ['req', 'proposalValidation']);
		    	self.frmvalidator.addValidation('current_stock', ['req', 'positiveNum']);
		    	self.frmvalidator.addValidation('stock', ['req', 'positiveNum']);
			} else if (self.page == 'Writers') {
				self.frmvalidator.addValidation('writer', ['req', 'minLength=3', 'maxLength=40']);
			} else if (self.page == 'Admin') {
				self.frmvalidator.addValidation('edit_username', ['req', 'minLength=3', 'maxLength=20']);
		    	self.frmvalidator.addValidation('edit_full_name', ['req', 'minLength=6', 'maxLength=40']);
		    	self.frmvalidator.addValidation('edit_password', ['req']);
		    	self.frmvalidator.addValidation('edit_priviledge', ['req']);
			}
			self.saveEdit();
			self.cancel();
		});
	}
	cancel(){
		var self = this;
		jQuery('[name="cancel"]').on('click', function(){
			var tds_text = JSON.parse(localStorage.getItem('for_cancel'));
			if (self.page == 'Admin') {
				var tds = $(this).parents('tr').find('td');
			} else {
				var tds = $(this).parents('form').find('table.main tbody tr td');
			}
			$.each(tds, function(key, td){
				$(td).html(tds_text[$(td).data('name')]);
			});
			var path = self.makeFormActionPath($(this).parents('form'), 'remove');
			$(this).parents('form').attr('action', root_url + path);
			if (self.page == 'Admin') {
				$(this).parent('div.btn-holder').html('<input type="button" name="edit" value="Edit" class="btn edit btn-info btn-sm"><input type="submit" name="remove" value="Remove" class="btn btn-danger ml-1 btn-sm remove">');
			} else {
				$(this).parent('div.btn-holder').html('<input type="button" name="edit" value="Edit" class="btn edit btn-info"><input type="submit" name="remove" value="Remove" class="btn btn-danger ml-1 remove">');
			}
			$('.edit, .remove').attr('disabled', false);
			if (self.page == 'Admin') {
				$('[type="hidden"]').attr('disabled', true);
			}
			$('.edit').off('click');
			self.tdToInput();
			if (self.page == 'Admin') {
				self.hiddenInputEnable();
			} else {
				self.setRemoveAlert();
			}
		});
	}
	makeFormActionPath(form, action){
		var path = '';
		if ($(form).attr('action').indexOf('Clients') >= 0) {
			if (action == 'remove') {
				path =  'Clients/removeClient';
			} else {
				path =  'Clients/editClientData';
			}
		} else if ($(form).attr('action').indexOf('Books') >= 0) {
			if (action == 'remove') {
				path =  'Books/removeBook';
			} else {
				path =  'Books/editBookData';
			}
		} else if ($(form).attr('action').indexOf('Writers') >= 0) {
			if (action == 'remove') {
				path =  'Writers/removeWriter';
			} else {
				path =  'Writers/editWriterData';
			}
		} else if ($(form).attr('action').indexOf('Admin') >= 0) {
			if (action == 'remove') {
				path =  'Admin/removeUser';
			} else {
				path =  'Admin/editUserData';
			}
		}
		return path;
	}
	validateBeforeSave(){
		return this.frmvalidator.validation($('form'));
	}
	saveEdit(){
		var self = this;
		jQuery('[name="save"]').on('click', function(e){
			e.preventDefault();
			if (self.validateBeforeSave()) {
				$(this).parents('form').submit();
			}
		});
	}
	// action used only on admin page for hidden input in edit user form
	hiddenInputEnable(){
		jQuery('.remove').on('click', function(e){
			e.preventDefault();
			$(this).parents('tr').find('[type="hidden"]').removeAttr('disabled');
			$(this).parents('form').submit();
		});
	}
	setRemoveAlert(){
		jQuery('.remove').on('click', function(e){
			e.preventDefault();
			if (confirm('Be aware that you can remove client or book only if there is no rentals where they were. Otherwise, client or book will be archived, not aviable for new rentals, but still present as info of past rentals.')) {
				$(this).parents('form').submit();
			} else {
				false;
			}
			
		});
	}
	makeChackboxesForGenres(){
		var html;
		$.ajax({
				type: "POST",
				url: root_url + "AjaxCalls/index",
				data: "ajax_fn=getAllGenres",
				success: function(data){
					var response = JSON.parse(data);
					$.each(response, function(key, value){
						html += '<div class="position-relative form-group"><input type="checkbox" value="'+ value.id +'" style="width: 100%" name="genres[]"  id="checkbox'+key+'" class="form-control"></div>';
					});
				},
				error: function(XMLHttpRequest, textStatus, errorThrown) {
			     	alert("some error"+errorThrown);
			 	}
			}).done(function(data){
				return html;
			});
	}
}