			</div>
		</div>
	<script type="text/javascript">
		$(document).ready(function() {
		  	$('li.active').removeClass('active');
			var url = location.pathname.split('/')[2];
			var nav_links = $('nav.navbar-dark a');
		  	for (var i = 0; i < nav_links.length; i++) {
		  		if (nav_links[i].pathname.split('/')[2] == url) {
		  			$(nav_links[i]).parent('li').addClass('active');
		  		}
		  	}
		  	var pagination_link = location.pathname.split('/')[3];
		  	if (pagination_link == 'index') {
		  		var pg_active = $('.pagination li a')[2];
		  		$(pg_active).parent('li').addClass('active');
		  	}
		  	$.each($('.pagination li a'), function(key, value){
		  		if ('p' + $(value).text() == pagination_link) {
		  			$(value).parent('li').addClass('active');
		  		}
		  	});
		});
	</script>
	</body>
</html>