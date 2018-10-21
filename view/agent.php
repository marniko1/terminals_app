		<div class="container">
			<div class="row">
				<?php
				// var_dump($this->data['agent']);
				?>
				<div class="col-12 mb-5 mt-5">
					<h2><?php echo $this->data['agent'][0]->agent; ?></h2> <small><?php echo $this->data['agent'][0]->off_num; ?></small>
				</div>
				<!-- discharge agent -->
				<form class="mb-5" method="post" action="<?php echo INCL_PATH.'Charges/discharge'; ?>">
					<!-- textarea for comment -->
					<div class="form-group">
					    <label for="comment">Komentar</label>
					    <textarea class="form-control" name="comment" id="comment" rows="6" cols="50"></textarea>
					</div>
					<input type="hidden" name="agent_id" value="<?php echo $this->data['agent'][0]->id; ?>">
					<div class="form-inline">
						<div class="form-check mr-2">
							<label class="form-check-label">
								<input type="hidden" name="terminal" class="form-check-input" value="0">
								<input type="checkbox" name="terminal" class="form-check-input" value="1">
								Terminal
							</label>
						</div>
						<div class="form-check mr-2">
							<label class="form-check-label">
								<input type="hidden" name="sim" class="form-check-input" value="0">
								<input type="checkbox" name="sim" class="form-check-input" value="1">
								SIM
							</label>
						</div>
						<div class="form-check mr-2">
							<label class="form-check-label">
								<input type="hidden" name="phone" class="form-check-input" value="0">
								<input type="checkbox" name="phone" class="form-check-input" value="1">
								Telefon
							</label>
						</div>
						<div class="form-check mr-2 ml-5">
							<label class="form-check-label">
								<input type="hidden" name="inactive" class="form-check-input" value="0">
								<input type="checkbox" name="inactive" class="form-check-input" value="1">
								Prebaci status u neaktivan
							</label>
						</div>
					</div>
					<input type="submit" class="btn btn-primary mt-2" value="Razduži">
				</form>
				<?php
				// var_dump($this->data['agent']);
				?>
				<table class="table table-sm writers">
					<caption>Zaduženi kontrolorski set</caption>
					<thead>
						<th scope="col" style="width: auto;">#</th>
					    <th scope="col" style="width: auto;">Terminal</th>
				      	<th scope="col" style="width: auto;">PDA</th>
				      	<th scope="col" style="width: auto;">Br.OS PDA</th>
				      	<th scope="col" style="width: auto;">Štampač</th>
				      	<th scope="col" style="width: auto;">Br.OS Štampač</th>
				      	<th scope="col" style="width: auto;">MTS broj</th>
				      	<th scope="col" style="width: auto;">ICCID</th>
					</thead>
					<tbody class="tbody">
						<tr>
							<th scope="row"><?php echo '1'; ?></th>
							<td><?php echo $this->data['agent'][0]->terminal_num; ?></td>
							<td><?php echo $this->data['agent'][0]->pda_sn; ?></td>
							<td><?php echo $this->data['agent'][0]->pda_nav_num; ?></td>
							<td><?php echo $this->data['agent'][0]->printer_sn; ?></td>
							<td><?php echo $this->data['agent'][0]->printer_nav_num; ?></td>
							<td><?php echo $this->data['agent'][0]->pda_sim; ?></td>
							<td><?php echo $this->data['agent'][0]->pda_sim_iccid; ?></td>
						</tr>
					</tbody>
				</table>
				<table class="table table-sm writers">
					<caption>Zaduženi kontrolorski telefon</caption>
					<thead>
						<th scope="col" style="width: auto;">#</th>
					    <th scope="col" style="width: auto;">Model</th>
				      	<th scope="col" style="width: auto;">IMEI</th>
				      	<th scope="col" style="width: auto;">Broj</th>
				      	<th scope="col" style="width: auto;">ICCID</th>
					</thead>
					<tbody class="tbody">
						<tr>
							<th scope="row"><?php echo '1'; ?></th>
							<td><?php echo $this->data['agent'][0]->phone_model; ?></td>
							<td><?php echo $this->data['agent'][0]->imei; ?></td>
							<td><?php echo $this->data['agent'][0]->num; ?></td>
							<td><?php echo $this->data['agent'][0]->iccid; ?></td>
						</tr>
					</tbody>
				</table>