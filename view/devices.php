		<div class="container">
			<div class="row">
				<h1>DEVICES</h1>
				<form class="mt-2 col-12 mb-5">
					<input type="text" name="filter" placeholder="Filter" id="filter">
				</form>
				<?php
				// var_dump($this->data['devices']);
				?>
				<table class="col-12 table table-sm">
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
					<?php if ($this->data['devices'][0]->sn != null):
					foreach ($this->data['devices'] as $key => $terminal) {
					?>
					<tr style="cursor: pointer;" onclick="document.location.href='<?php echo INCL_PATH.'Devices/'.$terminal->id; ?>'">
						<th scope="row"><?php echo $key + 1; ?></th>
						<td><?php echo $this->data['devices'][$key]->sn; ?></td>
						<td><?php echo $this->data['devices'][$key]->nav_num; ?></td>
						<td><?php echo $this->data['devices'][$key]->model; ?></td>
						<td><?php echo $this->data['devices'][$key]->type; ?></td>
						<td><?php echo $this->data['devices'][$key]->sw_ver; ?></td>
						<td><?php echo $this->data['devices'][$key]->writed_off; ?></td>
						<td><?php echo $this->data['devices'][$key]->location; ?></td>
					</tr>
					<?php
					}
					else: ?>
					<tr><td colspan="6">Nema napravljenih terminala.</td></tr>
					<?php endif ?>
					</tbody>
				</table>