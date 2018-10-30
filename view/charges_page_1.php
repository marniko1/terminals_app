		<div class="container">
			<div class="row">
				<h1>CHARGES</h1>
				<nav class="navbar col-12 row">
					<ul class="nav col-12 justify-content-center">
						<li class="nav-item border-right"><a class="nav-link" href="<?php echo INCL_PATH.'Charges/index';?>">Zaduženje</a></li>
						<li class="nav-item"><a class="nav-link" id="page_2_link" href="<?php echo INCL_PATH.'Charges/panel';?>">Razduženje</a></li>
					</ul>
				</nav>
				<form class="mt-5 row border rounded p-2" method="post" action="<?php echo INCL_PATH.'Charges/makeCharge'; ?>">
					<div class="col-12 form-inline border p-2">
						<div class="form-group row ml-2">
							<label class="mr-1" for="off_num">Službeni broj: </label>
							<input type="number" name="off_num" id="off_num" class="form-control col-4">
						</div>
						<div class="form-group row ml-4">
							<label class="mr-1" for="agent">Kontrolor: </label>
							<input type="text" name="agent" id="agent" class="form-control" disabled>
						</div>
					</div>
					<div class="col-12 form-inline mt-5 border p-2">
						<div class="form-group ml-2">
							<label class="mr-1" for="terminal">Terminal: </label>
							<input type="number" name="terminal" id="terminal" class="form-control col-5 proposal-input" disabled>
							<div class="proposals d-none">
								<ul class="mb-0 pl-0"></ul>
							</div>
						</div>
						<div class="form-group ml-2">
							<label class="mr-1" for="sim">SIM: </label>
							<input type="number" name="sim" id="sim" class="form-control col-5 proposal-input" disabled>
							<div class="proposals d-none">
								<ul class="mb-0 pl-0"></ul>
							</div>
						</div>
						<div class="form-group ml-2">
							<label class="mr-1" for="imei">Telefon IMEI: </label>
							<input type="text" name="imei" id="imei" class="form-control proposal-input" disabled>
							<div class="proposals d-none">
								<ul class="mb-0 pl-0"></ul>
							</div>
						</div>
						<div class="form-group ml-2">
							<input type="text" name="model" id="model" class="form-control" disabled>
							<input type="hidden" name="model" id="model_hidden">
						</div>
					</div>
					<div class="form-group row ml-5 mt-5">
						<input type="submit" name="submit" id="submit" value="Potvrdi" class="btn btn-primary submit" disabled="">
					</div>
					<?php echo (isset($this->data['msg']['msg1'])) ? "<span class='text-danger'>" . $this->data['msg']['msg1'] . "</span>" : false ?>
				</form>