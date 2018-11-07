		<div class="container">
			<div class="row">
				<nav class="navbar col-12 row">
					<ul class="nav col-12 justify-content-center">
						<li class="nav-item border-right"><a class="nav-link" href="<?php echo INCL_PATH.'SIMs/index';?>">Lista sim kartica</a></li>
						<li class="nav-item"><a class="nav-link" id="page_2_link" href="<?php echo INCL_PATH.'SIMs/panel';?>">Dodaj novi sim</a></li>
					</ul>
				</nav>
				<form class="form-inline mt-5" method="post" action="<?php echo INCL_PATH.'SIMs/addNewSIM'; ?>">
					<div class="form-group ml-2">
						<label for="network">Mreža 381: </label>
						<input type="number" name="network" id="network">
					</div>
					<div class="form-group ml-2">
						<label for="number">Broj: </label>
						<input type="number" name="number" id="number">
					</div>
					<div class="form-group ml-2">
						<label for="iccid">ICCID: </label>
						<input type="text" name="iccid" id="iccid">
					</div>
					<div class="form-group ml-2">
						<label for="purpose">Namena: </label>
						<input type="text" name="purpose" id="purpose">
					</div>
					<input type="submit" value="Potvrdi" class="btn btn-primary btn-sm ml-2 submit_btn">
					<input type="reset" value="Reset" class="btn btn-light btn-sm ml-2">
				</form>
				<div class="col-12"><?php echo (isset($this->data['msg']['msg1'])) ? "<span class='text-danger'>" . $this->data['msg']['msg1'] . "</span>" : false ?></div>