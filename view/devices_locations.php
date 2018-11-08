		<div class="container">
			<div class="row">
				<h1>LOCATIONS</h1>
				<?php
				// var_dump($this->data['locations']);
				?>
				<nav class="navbar col-12 row">
					<ul class="nav col-12 justify-content-center">
						<li class="nav-item border-right"><a class="nav-link" href="<?php echo INCL_PATH.'Devices/index';?>">Lista uređaja</a></li>
						<li class="nav-item"><a class="nav-link" id="page_2_link" href="<?php echo INCL_PATH.'Devices/panel';?>">Lokacije</a></li>
					</ul>
				</nav>
				<fieldset  class="customLegend row col-12">
					<legend>Prebaci uređaj na novu lokaciju</legend>
					<form class="form-inline mt-5" method="post" action="<?php echo INCL_PATH.'Devices/changeDeviceLocation'; ?>">
						<div class="form-group ml-2">
							<select class="form-control form-control-sm" name="location">
							  	<option value="/">--lokacija--</option>
							  	<?php
							  	foreach ($this->data['locations'] as $key => $location) {
							  		echo "<option value='$location->id'>$location->title</option>";
							  	}
							  	?>
							</select>
						</div>
						<div class="form-group ml-2">
							<label for="device">Uređaj: </label>
							<input type="text" class="proposal-input" id="device">
							<div class="proposals d-none">
								<ul class="mb-0 pl-0"></ul>
							</div>
						</div>
						<input type="hidden" name="location_id" id="location_id" value="">
						<input type="submit" value="Potvrdi" class="btn btn-primary btn-sm ml-2 submit_btn">
						<input type="reset" value="Reset" class="btn btn-light btn-sm ml-2">
					</form>
					<div class="col-12"><?php echo (isset($this->data['msg']['msg1'])) ? "<span class='text-danger'>" . $this->data['msg']['msg1'] . "</span>" : false ?></div>
				</fieldset>
				<fieldset  class="customLegend row col-12">
					<legend>Dodaj novu lokaciju</legend>
					<form class="form-inline mt-5 col-12" method="post" action="<?php echo INCL_PATH.'Locations/addNewLocation'; ?>">
						<div class="form-group ml-2">
								<label for="new_model">Naziv lokacije: </label>
								<input type="text" class="proposal-input" name="new_model" id="new_model">
						</div>
						<input type="hidden" name="page_url" value="<?php echo str_replace(INCL_PATH, '', $_SERVER['REQUEST_URI']); ?>">
						<input type="submit" value="Potvrdi" class="btn btn-primary btn-sm ml-2 submit_btn">
						<input type="reset" value="Reset" class="btn btn-light btn-sm ml-2">
					</form>
				</fieldset>
				<div class="col-12"><?php echo (isset($this->data['msg']['msg1'])) ? "<span class='text-danger'>" . $this->data['msg']['msg1'] . "</span>" : false ?></div>