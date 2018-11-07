class FilterAndPagination{
	constructor(filter, pagination_links, controller) {
		this.filter = filter;
		this.pagination_links = pagination_links;
		this.controller = controller;
		this.ajaxFilter();
	}
	ajaxFilter() {
		var controller = this.controller;
		var tbody = $('.tbody');
		var params = [];
		if (this.filter) {
			var filter = this.filter;
			var self = this;
			$(filter).on('keydown', function (e) {
				if(event.keyCode == 13) {
			      e.preventDefault();
			      return false;
			    }
			});
			$(filter).on('keyup', function () {
				var pagination = $('.pagination');
				var filter_value = filter.val().trim();
				pagination.removeClass('invisible');
				if ($('.pagination li.active')) {
					$('.pagination li.active').removeClass('active');
				}
				// **************************************************************
				// var params_holders_ids = ['#type', '#model', '#location', '#software_v', '#writed_off'];
				params = self.collectParams();
				
				// console.log(params);
				// **************************************************************
				var pg = 1;
				$.ajax({
					type: "POST",
					url: root_url + "AjaxCalls/index",
					data: "ajax_fn=" + controller.toLowerCase() + "Filter&search_value=" + filter_value + '&pg=' + pg + "&params=" + JSON.stringify(params),
					success: function(data){
						var response = JSON.parse(data);
						if (response[0].length > 0) {
							var tbody_html = self.prepareTbodyHTML(controller, response[0], response[2]);
							if (response[1].length == pagination_links.length) {
								self.paginationLinksChangeIfNoDiff(response[1], pagination_links);
							} else {
								// difference begins here
								var display_none_counter = 0;
								for (var i = 0; i < pagination_links.length; i++) {
									if ($(pagination_links[i]).hasClass('d-none')) {
										display_none_counter++;
									}
								}
								if (response[1].length - (pagination_links.length - display_none_counter) > 0) {	
									for (var i = pagination_links.length - display_none_counter; i <= response[1].length; i++) {
										$(pagination_links[i-1]).removeClass('d-none');
										$(pagination_links[i]).addClass('d-none');
									}
								} else {
									for (var i = pagination_links.length - 1; i >= response[1].length; i--) {
										$(pagination_links[i-1]).removeClass('d-none');
										$(pagination_links[i]).addClass('d-none');
									}
								}
								for (var i = 0; i < response[1].length; i++) {
									$(pagination_links[i]).attr('href', response[1][i][0]);
									$(pagination_links[i]).text(response[1][i][1]);
								}
							}
							// difference ends here
							self.finalAjaxDOMChanges(pagination_links, pg, tbody_html, tbody)
							// difference begins here
						} else {
							tbody.html('<tr><td colspan="6">No search results.</td></tr>');
							$(pagination).addClass('invisible');
						}
					},
					error: function(XMLHttpRequest, textStatus, errorThrown) {
				     	alert("some error"+errorThrown);
				 	}
				});
			});
		}
		if (this.pagination_links) {
			var pagination_links = this.pagination_links;
			var self = this;
			$(pagination_links).on('click', function (e) {
				e.preventDefault();
				$('.pagination li.active').removeClass('active');
				var filter_value = '';
				if (filter) {
					filter_value = $(filter).val().trim();
				}
				// **************************************************************
				// var params_holders_ids = ['#type', '#model', '#location', '#software_v', '#writed_off'];
				params = self.collectParams();
				
				// console.log(params);
				// **************************************************************
			  	var pg = this.href.split('/').reverse()[0].replace('p', '');
			  	var id = window.location.href.split('/').reverse()[1];
			  	$.ajax({
					type: "POST",
					url: root_url + "AjaxCalls/index",
					data: "ajax_fn=" + controller.toLowerCase() + "Filter&search_value=" + filter_value + '&pg=' + pg + "&params=" + JSON.stringify(params),
					success: function(data){
						var response = JSON.parse(data);
						if (response[0].length > 0) {
							var tbody_html = self.prepareTbodyHTML(controller, response[0], response[2]);
							if (response[1].length == pagination_links.length) {
								self.paginationLinksChangeIfNoDiff(response[1], pagination_links);
							} else {
								var diff = pagination_links.length - response[1].length;
								if (diff != 0) {
									for (var i = pagination_links.length - 1; i >= response[1].length; i--) {
										$(pagination_links[i-1]).removeClass('d-none');
										$(pagination_links[i]).addClass('d-none');
									}
								}
								for (var i = 0; i < response[1].length; i++) {
									$(pagination_links[i]).attr('href', response[1][i][0]);
									$(pagination_links[i]).text(response[1][i][1]);
								}
							}
							self.finalAjaxDOMChanges(pagination_links, pg, tbody_html, tbody);
						} else {
							$(pagination_links[1]).parent().addClass('active');
						}
					},
					error: function(XMLHttpRequest, textStatus, errorThrown) {
				     	alert("some error"+errorThrown);
				 	}
				});
			});
		}
		// **************************************************************************
		// 
		//                testing
		// 
		// ************************************************************************** //
		$('.params select').on('click', function (){
			var pagination = $('.pagination');
			var filter_value = filter.val().trim();
			pagination.removeClass('invisible');
			if ($('.pagination li.active')) {
				$('.pagination li.active').removeClass('active');
			}
			// **************************************************************
			// var params_holders_ids = ['#type', '#model', '#location', '#software_v', '#writed_off'];
			params = self.collectParams();
			
			// console.log(params);
			// **************************************************************
			var pg = 1;
			$.ajax({
				type: "POST",
				url: root_url + "AjaxCalls/index",
				data: "ajax_fn=" + controller.toLowerCase() + "Filter&search_value=" + filter_value + '&pg=' + pg + "&params=" + JSON.stringify(params),
				success: function(data){
					var response = JSON.parse(data);
					if (response[0].length > 0) {
						var tbody_html = self.prepareTbodyHTML(controller, response[0], response[2]);
						if (response[1].length == pagination_links.length) {
							self.paginationLinksChangeIfNoDiff(response[1], pagination_links);
						} else {
							// difference begins here
							var display_none_counter = 0;
							for (var i = 0; i < pagination_links.length; i++) {
								if ($(pagination_links[i]).hasClass('d-none')) {
									display_none_counter++;
								}
							}
							if (response[1].length - (pagination_links.length - display_none_counter) > 0) {	
								for (var i = pagination_links.length - display_none_counter; i <= response[1].length; i++) {
									$(pagination_links[i-1]).removeClass('d-none');
									$(pagination_links[i]).addClass('d-none');
								}
							} else {
								for (var i = pagination_links.length - 1; i >= response[1].length; i--) {
									$(pagination_links[i-1]).removeClass('d-none');
									$(pagination_links[i]).addClass('d-none');
								}
							}
							for (var i = 0; i < response[1].length; i++) {
								$(pagination_links[i]).attr('href', response[1][i][0]);
								$(pagination_links[i]).text(response[1][i][1]);
							}
						}
						// difference ends here
						self.finalAjaxDOMChanges(pagination_links, pg, tbody_html, tbody)
						// difference begins here
					} else {
						tbody.html('<tr><td colspan="6">No search results.</td></tr>');
						$(pagination).addClass('invisible');
					}
				},
				error: function(XMLHttpRequest, textStatus, errorThrown) {
			     	alert("some error"+errorThrown);
			 	}
			});

		});
		// 
		// **************************************************************************
		// 
	}
	finalAjaxDOMChanges(pagination_links, pg, tbody_html, tbody) {
		this.addActiveToPaginationLink(pagination_links, pg);
		this.changeTbodyHTML (tbody_html, tbody);
	}
	addActiveToPaginationLink(pagination_links, pg) {
		$.each(pagination_links, function(key, link){
			if ($(link).text() == pg) {
				$(link).parent().addClass('active');
			}
		});
	}
	paginationLinksChangeIfNoDiff(response, pagination_links){
		$.each(pagination_links, function(key, link){
			$(link).removeClass('d-none');
			$(link).attr('href', response[key][0]);
			$(link).text(response[key][1]);
		});
	}
	changeTbodyHTML (tbody_html, tbody) {
		var tbody = tbody;
		tbody.html(tbody_html);
	}
	prepareTbodyHTML(controller, response, skip) {
		var tbody_html = ``;
		for (var i = 0; i < response.length; i++) {
			tbody_html += `<tr style="cursor: pointer" onclick="document.location.href='${root_url + controller}/${response[i].id}'">
			<th scope="row">${++skip}</th>`;
			for (var key in response[i]) {
				if (key != 'id' && key != 'total') {
					if (response[i][key] == null) {
						response[i][key] = '';
					}
					tbody_html += `<td>${response[i][key]}</td>`
				}
			}
			tbody_html += `</tr>`
		}
		return tbody_html;
	}
	collectParams(){
		var params_holders_ids = [];
		var params = {};
		var elements = $('.params input, select');
		$.each(elements, function(key, element){
			params_holders_ids.push('#' + $(element).attr('id'));
		});
		$.each(params_holders_ids, function(key, param){
			params[param.replace('#', '')] = $(param).val();
		});
		return params;
	}
}