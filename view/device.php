		<div class="container">
			<div class="row">
				<h1>single DEVICE</h1>
				<?php
				// var_dump($this->data['device']);
				?>
				<table class="col-12 table table-sm mt-5">
						<caption>Lista terminala</caption>
						<thead>
							<th scope="col" style="width: auto;">#</th>
						    <th scope="col" style="width: auto;">Serijski broj</th>
					      	<th scope="col" style="width: auto;">Br.OS</th>
					      	<th scope="col" style="width: auto;">Model</th>
					      	<th scope="col" style="width: auto;">Tip</th>
					      	<th scope="col" style="width: auto;">Software v.</th>
					      	<th scope="col" style="width: auto;">Otpisan</th>
					      	<th scope="col" style="width: auto;">Lokacija</th>
						</thead>
						<tbody class="tbody">
							<tr>
								<th scope="row"><?php echo '1'; ?></th>
								<td><?php echo $this->data['device'][0]->sn; ?></td>
								<td><?php echo $this->data['device'][0]->nav_num; ?></td>
								<td><?php echo $this->data['device'][0]->model; ?></td>
								<td><?php echo $this->data['device'][0]->type; ?></td>
								<td><?php echo $this->data['device'][0]->sw_ver; ?></td>
								<td><?php echo $this->data['device'][0]->writed_off; ?></td>
								<td><?php echo $this->data['device'][0]->location; ?></td>
							</tr>
						</tbody>
					</table>