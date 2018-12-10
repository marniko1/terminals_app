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
				<h1>ADMINISTRACIJA SERVISA</h1>
				<fieldset  class="customLegend row col-12">
					<legend>Dodaj novi servisni pojam</legend>
					<form class="form-inline mt-5 col-12" method="post" action="<?php echo INCL_PATH.'Models/addNewModel'; ?>">
						<div class="form-group ml-2">
							<select class="form-control form-control-sm" name="model">
							  	<option value="/">--vrsta pojma--</option>
							  	<option value="/">Opis kvara</option>
							  	<option value="/">Rešanje kvara</option>
							</select>
						</div>
						<div class="form-group ml-2">
								<label for="new_model">Naziv: </label>
								<input type="text" class="proposal-input" name="new_model" id="new_model">
						</div>
						<input type="hidden" name="page_url" value="<?php echo str_replace(INCL_PATH, '', $_SERVER['REQUEST_URI']); ?>">
						<input type="hidden" name="purpose" value="phone">
						<input type="submit" value="Potvrdi" class="btn btn-primary btn-sm ml-2 submit_btn">
						<input type="reset" value="Reset" class="btn btn-light btn-sm ml-2">
					</form>
				</fieldset>
				<div class="col-12"><?php echo (isset($this->data['msg']['msg1'])) ? "<span class='text-danger'>" . $this->data['msg']['msg1'] . "</span>" : false ?></div>