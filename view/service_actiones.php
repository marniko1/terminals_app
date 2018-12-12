		<div class="container">
			<div class="row">
				<div class="col-12 text-center mt-5 p-5">
					<img src="<?php  echo INCL_PATH.'assets/images/under_construction.gif'?>" class="mt-5">
				</div>
				<nav class="navbar col-12 row">
					<ul class="nav col-12 justify-content-center">
						<li class="nav-item border-right"><a class="nav-link" href="<?php echo INCL_PATH.'Service/index';?>">Početna</a></li>
						<li class="nav-item border-right"><a class="nav-link" href="<?php echo INCL_PATH.'Service/panel';?>">Servisne akcije</a></li>
						<li class="nav-item"><a class="nav-link" id="page_2_link" href="<?php echo INCL_PATH.'Service/admin';?>">Administracija servisa</a></li>
					</ul>
				</nav>
				<h1 class="col-12 mb-5">SERVISNE AKCIJE</h1>
				<nav class="nav flex-column nav-tabs col-2 border-bottom-0 pr-0">
				  	<a class="nav-link service_action_links" href="#" id="switch">Zamena PDA</a>
				  	<a class="nav-link service_action_links" href="#" id="write_off">Otpis uređaja</a>
				  	<a class="nav-link service_action_links" href="#" id="test">Link</a>
				  	<!-- <a class="nav-link disabled" href="#">Disabled</a> -->
				</nav>
				<div class="col-10 border">
					<div class="d-none service_action_divs" id="switch_div">zamena</div>
					<div class="d-none service_action_divs" id="write_off_div">otpis</div>
					<div class="d-none service_action_divs" id="test_div">test test</div>
				</div>