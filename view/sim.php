		<div class="container mt-5">
			<div class="row">
				<div  class="table-holder" style="min-height: 450px; width:100%">
					<table class="col-12 table table-sm mt-5">
						<caption>SIM</caption>
						<thead>
							<th scope="col" style="width: auto;">#</th>
						    <th scope="col" style="width: auto;">Broj</th>
					      	<th scope="col" style="width: auto;">ICCID</th>
					      	<th scope="col" style="width: auto;">Namena</th>
						</thead>
						<tbody class="tbody">
							<tr>
								<th scope="row"><?php echo '1'; ?></th>
								<td><?php echo '+' . $this->data['sim'][0]->network . '/' . $this->data['sim'][0]->num; ?></td>
								<td><?php echo $this->data['sim'][0]->iccid; ?></td>
								<td><?php echo $this->data['sim'][0]->purpose; ?></td>
							</tr>
						</tbody>
					</table>