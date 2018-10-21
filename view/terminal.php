		<div class="container">
			<div class="row">
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
					      	<th scope="col" style="width: auto;">Lokacija</th>
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
								<td><?php echo $this->data['terminal'][0]->location; ?></td>
							</tr>
						</tbody>
					</table>
					<input type="hidden" name="client_id" value="<?php echo $this->data['terminal'][0]->id; ?>">
					<div class="btn-holder">
						<input type="button" name="edit" value="Edit" class="btn edit btn-info">
						<input type="submit" name="remove" value="Remove" class="btn btn-danger remove">
					</div>
				</form>