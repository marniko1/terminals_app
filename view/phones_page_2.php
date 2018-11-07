		<div class="container">
			<div class="row">
				<nav class="navbar col-12 row">
					<ul class="nav col-12 justify-content-center">
						<li class="nav-item border-right"><a class="nav-link" href="<?php echo INCL_PATH.'Phones/index';?>">Lista telefona</a></li>
						<li class="nav-item"><a class="nav-link" id="page_2_link" href="<?php echo INCL_PATH.'Phones/panel';?>">Dodaj novi telefon</a></li>
					</ul>
				</nav>
				<fieldset  class="customLegend row col-12">
					<legend>Dodaj novi telefon</legend>
					<form class="form-inline mt-5" method="post" action="<?php echo INCL_PATH.'Phones/addNewPhone'; ?>">
						<div class="form-group ml-2">
							<select class="form-control form-control-sm" name="model">
							  	<option value="/">--model--</option>
							  	<?php
							  	foreach ($this->data['phones_models'] as $key => $phone_model) {
							  		echo "<option value='$phone_model->id'>$phone_model->title</option>";
							  	}
							  	?>
							</select>
						</div>
						<div class="form-group ml-2">
								<label for="new_phone_imei">IMEI: </label>
								<input type="text" class="proposal-input" name="new_phone_imei" id="new_phone_imei">
						</div>
						<input type="submit" value="Potvrdi" class="btn btn-primary btn-sm ml-2 submit_btn">
						<input type="reset" value="Reset" class="btn btn-light btn-sm ml-2">
					</form>
					<div class="col-12"><?php echo (isset($this->data['msg']['msg1'])) ? "<span class='text-danger'>" . $this->data['msg']['msg1'] . "</span>" : false ?></div>
				</fieldset>
				<fieldset  class="customLegend row col-12">
					<legend>Dodaj novi model telefona</legend>
					<form class="form-inline mt-5 col-12" method="post" action="<?php echo INCL_PATH.'Models/addNewModel'; ?>">
						<div class="form-group ml-2">
								<label for="new_model">Naziv modela: </label>
								<input type="text" class="proposal-input" name="new_model" id="new_model">
						</div>
						<input type="hidden" name="page_url" value="<?php echo str_replace(INCL_PATH, '', $_SERVER['REQUEST_URI']); ?>">
						<input type="hidden" name="purpose" value="phone">
						<input type="submit" value="Potvrdi" class="btn btn-primary btn-sm ml-2 submit_btn">
						<input type="reset" value="Reset" class="btn btn-light btn-sm ml-2">
					</form>
				</fieldset>
				<div class="col-12"><?php echo (isset($this->data['msg']['msg1'])) ? "<span class='text-danger'>" . $this->data['msg']['msg1'] . "</span>" : false ?></div>