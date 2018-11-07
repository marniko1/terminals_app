		<div class="container">
			<div class="row">
				<nav class="navbar col-12 row">
					<ul class="nav col-12 justify-content-center">
						<li class="nav-item border-right"><a class="nav-link" href="<?php echo INCL_PATH.'Terminals/index';?>">Lista terminala</a></li>
						<li class="nav-item"><a class="nav-link" id="page_2_link" href="<?php echo INCL_PATH.'Terminals/panel';?>">Sastavi terminal</a></li>
					</ul>
				</nav>
				<form class="form-inline mt-5" method="post" action="<?php echo INCL_PATH.'Terminals/addNewTerminal'; ?>">
					<div class="form-group ml-2">
						<label for="terminal_num">Terminal Br.: </label>
						<input type="text" class="proposal-input" name="terminal_num" id="terminal_num">
						<div class="proposals d-none">
							<ul class="mb-0 pl-0"></ul>
						</div>
					</div>
					<div class="form-group ml-2">
						<label for="pda">PDA: </label>
						<input type="text" class="proposal-input" name="pda" id="pda">
						<div class="proposals d-none">
							<ul class="mb-0 pl-0"></ul>
						</div>
					</div>
					<div class="form-group ml-2">
						<label for="printer">Štampač: </label>
						<input type="text" class="proposal-input" name="printer" id="printer">
						<div class="proposals d-none">
							<ul class="mb-0 pl-0"></ul>
						</div>
					</div>
					<div class="form-group ml-2">
						<label for="pda_sim_for_new_terminal">pdaSIM: </label>
						<input type="text" class="proposal-input" name="pda_sim_for_new_terminal" id="pda_sim_for_new_terminal">
						<div class="proposals d-none">
							<ul class="mb-0 pl-0"></ul>
						</div>
					</div>
					<input type="submit" value="Potvrdi" class="btn btn-primary btn-sm ml-2 submit_btn" id="submit_btn">
					<input type="reset" value="Reset" class="btn btn-light btn-sm ml-2">
				</form>
				<div class="col-12"><?php echo (isset($this->data['msg']['msg1'])) ? "<span class='text-danger'>" . $this->data['msg']['msg1'] . "</span>" : false ?></div>