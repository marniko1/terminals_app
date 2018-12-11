		<div class="container">
			<div class="row">
				<div class="col-12 mb-5 mt-5">
					<h2><?php echo $this->data['agent'][0]->agent; ?></h2> <small><?php echo $this->data['agent'][0]->off_num; ?></small>
				</div>
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
				      	<th scope="col" style="width: auto;">Datum zaduženja</th>
					</thead>
					<tbody class="tbody">
						<tr>
							<th scope="row"><?php echo '1'; ?></th>
							<td id="terminal"><?php echo $this->data['agent'][0]->terminal_num; ?></td>
							<td><?php echo $this->data['agent'][0]->pda_sn; ?></td>
							<td><?php echo $this->data['agent'][0]->pda_nav_num; ?></td>
							<td><?php echo $this->data['agent'][0]->printer_sn; ?></td>
							<td><?php echo $this->data['agent'][0]->printer_nav_num; ?></td>
							<td><?php echo $this->data['agent'][0]->pda_sim; ?></td>
							<td><?php echo $this->data['agent'][0]->pda_sim_iccid; ?></td>
							<td><?php echo $this->data['agent'][0]->terminal_charge_date; ?></td>
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
							<td id="phone"><?php echo $this->data['agent'][0]->imei; ?></td>
							<td id="sim"><?php echo $this->data['agent'][0]->num; ?></td>
							<td><?php echo $this->data['agent'][0]->iccid; ?></td>
						</tr>
					</tbody>
				</table>
				<!-- discharge agent -->
				<form id="discharge_form" class="mb-5 border col-6 mt-5 p-2" method="post" action="<?php echo INCL_PATH.'Charges/discharge'; ?>">
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
						<div class="form-group mt-4">
							<input type="checkbox" name="send_mail" id="send_mail" class="form-check-input" value="1">
							<label for="send_mail" class="form-check-label">Pošalji propratni mail</label>
						</div>
					</div>
					<input type="hidden" name="agent" value="<?php echo $this->data['agent'][0]->agent; ?>">
					<input type="hidden" name="off_num" value="<?php echo $this->data['agent'][0]->off_num; ?>">
					<input type="hidden" name="terminal_num" value="<?php echo $this->data['agent'][0]->terminal_num; ?>">
					<input type="hidden" name="sim_num" value="<?php echo $this->data['agent'][0]->num; ?>">
					<input type="hidden" name="imei" value="<?php echo $this->data['agent'][0]->imei; ?>">
					<input type="hidden" name="phone_model" value="<?php echo $this->data['agent'][0]->phone_model; ?>">
					<input type="submit" class="btn btn-primary mt-2" id="discharge_btn" value="Razduži" disabled>
				</form>