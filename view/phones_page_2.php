		<div class="container">
			<div class="row">
				<h1>ADD PHONES</h1>
				<?php
				// var_dump($this->data['phones_models']);
				?>
				<nav class="navbar col-12 row">
					<ul class="nav col-12 justify-content-center">
						<li class="nav-item border-right"><a class="nav-link" href="<?php echo INCL_PATH.'Phones/index';?>">Lista telefona</a></li>
						<li class="nav-item"><a class="nav-link" id="page_2_link" href="<?php echo INCL_PATH.'Phones/panel';?>">Dodaj novi telefon</a></li>
					</ul>
				</nav>
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
							<label for="imei">IMEI: </label>
							<input type="text" class="proposal-input" name="imei" id="imei">
					</div>
					<input type="submit" name="submit" value="Potvrdi" class="btn btn-primary btn-sm ml-2">
					<input type="reset" value="Reset" class="btn btn-light btn-sm ml-2">
				</form>
				<div class="col-12"><?php echo (isset($this->data['msg']['msg1'])) ? "<span class='text-danger'>" . $this->data['msg']['msg1'] . "</span>" : false ?></div>