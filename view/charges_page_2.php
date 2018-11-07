		<div class="container">
			<div class="row">
				<nav class="navbar col-12 row">
					<ul class="nav col-12 justify-content-center">
						<li class="nav-item border-right"><a class="nav-link" href="<?php echo INCL_PATH.'Charges/index';?>">Zaduženje</a></li>
						<li class="nav-item"><a class="nav-link" id="page_2_link" href="<?php echo INCL_PATH.'Charges/panel';?>">Razduženje</a></li>
					</ul>
				</nav>
				<form class="mt-5 border rounded p-2" method="post">
					<div class="form-group ml-2">
						<label class="mr-1" for="search">Pretraga kontrolora: </label>
						<input type="text" name="search" id="search" class="form-control">
					</div>
					<div class="form-group ml-5">
						<input type="submit" name="submit" value="Potvrdi" class="btn btn-primary">
					</div>
					<?php echo (isset($this->data['msg']['msg1'])) ? "<span class='text-danger'>" . $this->data['msg']['msg1'] . "</span>" : false ?>
				</form>