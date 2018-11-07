		<div class="container">
			<div class="row">
				<?php
				// var_dump($this->data['terminal']);
				?>
				<form method="post" action="<?php echo INCL_PATH.'Terminals/removeTerminal';?>" class="edit_form col-12 mt-5">
					<table class="table table-sm writers">
						<caption>Lista terminala</caption>
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
								<td><?php echo $this->data['terminal'][0]->terminal_num; ?></td>
								<td><?php echo $this->data['terminal'][0]->pda_sn; ?></td>
								<td><?php echo $this->data['terminal'][0]->pda_nav_num; ?></td>
								<td><?php echo $this->data['terminal'][0]->printer_sn; ?></td>
								<td><?php echo $this->data['terminal'][0]->printer_nav_num; ?></td>
								<td><?php echo $this->data['terminal'][0]->num; ?></td>
								<td><?php echo $this->data['terminal'][0]->iccid; ?></td>
							</tr>
						</tbody>
					</table>
					<input type="hidden" name="client_id" value="<?php echo $this->data['terminal'][0]->id; ?>">
					<div class="btn-holder">
						<input type="submit" name="remove" value="Rastavi terminal" class="btn btn-danger remove" disabled>
					</div>
				</form>
				<?php if (!$this->data['terminal'][0]->disassembled): ?>
					<span class="col-12 mt-5">Trenutna lokacija: <?php echo '<span id="location_span">' . 
					$this->data['terminal'][0]->location . 
					"</span><a href='" . 
					INCL_PATH.'Agents/' . 
					$this->data['terminal'][0]->current_agent_id .
					"'>" . 
					$this->data['terminal'][0]->current_agent . 
					"</a>"; ?></span>
				<?php else: ?>
					<span class="col-12 mt-5">Set je rasturen.</span>
				<?php endif ?>
				<table class="table table-sm mt-5">
						<caption>Istorija zaduženja</caption>
						<thead>
							<th scope="col" style="width: auto;">#</th>
						    <th scope="col" style="width: auto;">Kontrolor</th>
					      	<th scope="col" style="width: auto;">Datum zaduženja</th>
					      	<th scope="col" style="width: auto;">Datum razduženja</th>
						</thead>
						<tbody class="tbody">
							<?php if ($this->data['terminal'][0]->charge_date != null):
							foreach ($this->data['terminal'] as $key => $charge) {
							?>
							<tr>
								<th scope="row"><?php echo $key + 1; ?></th>
								<td><?php echo $charge->agent; ?></td>
								<td><?php echo $charge->charge_date; ?></td>
								<td><?php echo $charge->charge_off_date; ?></td>
							</tr>
							<?php
							}
							else: ?>
							<tr><td colspan="6">Nema napravljenih zaduženja za dati terminal.</td></tr>
							<?php endif ?>
							</tbody>
						</tbody>
					</table>