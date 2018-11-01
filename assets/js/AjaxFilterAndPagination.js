class FilterAndPagination{
	constructor(filter, pagination_links, controller) {
		this.filter = filter;
		this.pagination_links = pagination_links;
		this.controller = controller;
		this.ajaxFilter();
	}
	ajaxFilter() {
		var controller = this.controller;
		var tbody = document.querySelector('.tbody');
		if (this.filter) {
			var filter = this.filter;
			var self = this;
			filter.onkeydown = function (e) {
				if(event.keyCode == 13) {
			      e.preventDefault();
			      return false;
			    }
			}
			filter.onkeyup = function () {
				var pagination = document.querySelector('.pagination');
				var filter_value = filter.value.trim();
				pagination.classList.remove('invisible');
				if (document.querySelector('.pagination li.active')) {
					document.querySelector('.pagination li.active').classList.remove('active');
				}
				var pg = 1;
				var httpReq = new XMLHttpRequest ();

				httpReq.open('post', root_url + "AjaxCalls/index");
				httpReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
				httpReq.send('ajax_fn=' + controller.toLowerCase() + 'Filter&search_value='+ filter_value + '&pg=' + pg);

				httpReq.onreadystatechange = function(){
					if (httpReq.readyState == 4){
						var response = JSON.parse(this.responseText);
						if (response[0].length > 0) {
							var tbody_html = self.prepareTbodyHTML(controller, response[0], response[2]);
							if (response[1].length == pagination_links.length) {
								self.paginationLinksChangeIfNoDiff(response[1], pagination_links);
							} else {
								// difference begins here
								var display_none_counter = 0;
								for (var i = 0; i < pagination_links.length; i++) {
									if (pagination_links[i].classList.contains('d-none')) {
										display_none_counter++;
									}
								}
								if (response[1].length - (pagination_links.length - display_none_counter) > 0) {	
									for (var i = pagination_links.length - display_none_counter; i <= response[1].length; i++) {
										pagination_links[i-1].classList.remove('d-none');
										pagination_links[i].classList.add('d-none');
									}
								} else {
									for (var i = pagination_links.length - 1; i >= response[1].length; i--) {
										pagination_links[i-1].classList.remove('d-none');
										pagination_links[i].classList.add('d-none');
									}
								}
								for (var i = 0; i < response[1].length; i++) {
									pagination_links[i].href = response[1][i][0];
									pagination_links[i].innerText = response[1][i][1];
								}
							}
							// difference ends here
							self.finalAjaxDOMChanges(pagination_links, pg, tbody_html, tbody)
							// difference begins here
						} else {
							tbody.innerHTML = '<tr><td colspan="6">No search results.</td></tr>';
							pagination.classList.add('invisible');
						}
						// difference ends here
					}
				}
			}
		}
		if (this.pagination_links) {
			var pagination_links = this.pagination_links;
			for (var i = 0; i < pagination_links.length; i++) {
				var link = pagination_links[i];
				var self = this;
				link.onclick = function (e) {
					e.preventDefault();
					document.querySelector('.pagination li.active').classList.remove('active');
					var filter_value = '';
					if (filter) {
						filter_value = filter.value.trim();
					}

				  	var pg = this.href.split('/').reverse()[0].replace('p', '');
				  	var id = window.location.href.split('/').reverse()[1];
					var httpReq = new XMLHttpRequest ();

				  	httpReq.open('post', root_url + "AjaxCalls/index");
					httpReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
					httpReq.send('ajax_fn=' + controller.toLowerCase() + 'Filter&search_value='+ filter_value + '&pg=' + pg + '&id=' + id);

					httpReq.onreadystatechange = function(){
						if (httpReq.readyState == 4){
							var response = JSON.parse(this.responseText);
							if (response[0].length > 0) {
								var tbody_html = self.prepareTbodyHTML(controller, response[0], response[2]);
								if (response[1].length == pagination_links.length) {
									self.paginationLinksChangeIfNoDiff(response[1], pagination_links);
								} else {
									var diff = pagination_links.length - response[1].length;
									if (diff != 0) {
										for (var i = pagination_links.length - 1; i >= response[1].length; i--) {
											pagination_links[i-1].classList.remove('d-none');
											pagination_links[i].classList.add('d-none');
										}
									}
									for (var i = 0; i < response[1].length; i++) {
										pagination_links[i].href = response[1][i][0];
										pagination_links[i].innerText = response[1][i][1];
									}
								}
								self.finalAjaxDOMChanges(pagination_links, pg, tbody_html, tbody);
							} else {
								pagination_links[1].parentElement.classList.add('active');
							}
						}
					}
				}
			}
		}
	}
	finalAjaxDOMChanges(pagination_links, pg, tbody_html, tbody) {
		this.addActiveToPaginationLink(pagination_links, pg);
		this.changeTbodyHTML (tbody_html, tbody);
	}
	addActiveToPaginationLink(pagination_links, pg) {
		for (var i = 0; i < pagination_links.length; i++) {
			if (pagination_links[i].innerText == pg) {
				pagination_links[i].parentElement.classList.add('active');
			}
		}
	}
	paginationLinksChangeIfNoDiff(response, pagination_links){
		for (var i = 0; i < response.length; i++) {
			pagination_links[i].classList.remove('d-none');
			pagination_links[i].href = response[i][0];
			pagination_links[i].innerText = response[i][1];
		}
	}
	changeTbodyHTML (tbody_html, tbody) {
		var tbody = tbody;
		tbody.innerHTML = tbody_html;
	}
	prepareTbodyHTML(controller, response, skip) {
		var tbody_html = ``;
		// need this for single book and single client all rentals pagination-----
		var pg = '';
		if (controller == 'Books' || controller == 'Clients' || controller == 'Writers') {
			pg = '/p1';
		}
		// -------------
		for (var i = 0; i < response.length; i++) {
			if (controller == 'Book' || controller == 'Client') {
				controller = 'Rentals';
			}
			if (controller == 'Writer') {
				controller = 'Books';
				pg = '/p1';
			}
			tbody_html += `<tr style="cursor: pointer" onclick="document.location.href='${root_url + controller}/${response[i].id + pg}'">
			<th scope="row">${++skip}</th>`;
			for (var key in response[i]) {
				if (key != 'id' && key != 'long_genre' && key != 'total' && key != 'rented') {
					if (key != 'genre') {
						tbody_html += `<td>${response[i][key]}</td>`;
					} else {
						tbody_html += `<td title="${response[i].long_genre}">${response[i][key]}</td>`
					}
				}
			}
			tbody_html += `</tr>`
		}
		return tbody_html;
	}
}