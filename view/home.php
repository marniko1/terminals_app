		<div class="container">
			<div class="row">
				<div id="home_page_main" class="mt-5 col-12">
					<div class="border border-success rounded p-3">
						<h2 class="col-12 text-center mb-5">KONTROLORSKI KOMPLETI</h2>
						<div class="row mt-4 text-center">
							<div class="col-4">
								<h3>UKUPNO: </h3> <span class="display-1 font-weight-bold"><?php echo $this->data['terminals_num'][0]->terminals_num; ?></span>
							</div>
							<div class="col-4">
								<h3>U MAGACINU: </h3> <span class="display-1 font-weight-bold"><?php echo $this->data['terminals_num_in_storage'][0]->terminals_num_in_storage; ?></span>
							</div>
							<div class="col-4">
								<h3>KONTROLA: </h3> <span class="display-1 font-weight-bold"><?php echo $this->data['charged_terminals_num'][0]->charged_terminals_num; ?></span>
							</div>
						</div>
					</div>
					<?php if ($_SESSION['priviledge'] == 'admin' || $_SESSION['priviledge'] == 'service'): ?>
						<div class="border border-success rounded p-3">
							<h2 class="col-12 text-center mb-5">PDA</h2>
							<div class="row mt-4 text-center">
								<div class="col-3">
									<h3>UKUPNO: </h3> <span class="display-1 font-weight-bold"><?php echo $this->data['pda_num'][0]->pda_num; ?></span>
								</div>
								<div class="col-3">
									<h3>U MAGACINU: </h3> <span class="display-1 font-weight-bold"><?php echo $this->data['pda_num_in_storage'][0]->pda_num_in_storage; ?></span>
								</div>
								<div class="col-3">
									<h3>U SETU: </h3> <span class="display-1 font-weight-bold"><?php echo $this->data['pda_num_in_terminals'][0]->pda_num_in_terminals; ?></span>
								</div>
								<div class="col-3">
									<h3>OSTALE LOKACIJE: </h3> <span class="display-1 font-weight-bold"><?php echo $this->data['pda_num_on_other_locations'][0]->pda_num_on_other_locations; ?></span>
								</div>
							</div>
						</div>
						<div class="border border-success rounded p-3">
							<h2 class="col-12 text-center mb-5">ŠTAMPAČ</h2>
							<div class="row mt-4 text-center">
								<div class="col-3">
									<h3>UKUPNO: </h3> <span class="display-1 font-weight-bold"><?php echo $this->data['printers_num'][0]->printers_num; ?></span>
								</div>
								<div class="col-3">
									<h3>U MAGACINU: </h3> <span class="display-1 font-weight-bold"><?php echo $this->data['printers_num_in_storage'][0]->printers_num_in_storage; ?></span>
								</div>
								<div class="col-3">
									<h3>U SETU: </h3> <span class="display-1 font-weight-bold"><?php echo $this->data['printers_num_in_terminals'][0]->printers_num_in_terminals; ?></span>
								</div>
								<div class="col-3">
									<h3>OSTALE LOKACIJE: </h3> <span class="display-1 font-weight-bold"><?php echo $this->data['printers_num_on_other_locations'][0]->printers_num_on_other_locations; ?></span>
								</div>
							</div>
						</div>
					<?php endif ?>
				</div>