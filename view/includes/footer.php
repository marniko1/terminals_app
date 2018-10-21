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
		});
		$(document).ready(function() {
			var first_pagination_link = document.querySelectorAll('.pagination li a');
			$(first_pagination_link[2]).parent('li').addClass('active');
		});
	</script>
	</body>
</html>