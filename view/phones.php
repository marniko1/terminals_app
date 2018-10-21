		<div class="container">
			<div class="row">
				<h1>PHONES</h1>
				<form class="mt-2 col-12 mb-5">
					<input type="text" name="filter" placeholder="Filter" id="filter">
				</form>
				<?php
				// var_dump($this->data['phones']);
				?>
				<table class="col-12 table table-sm">
					<caption>Lista mobilnih telefona</caption>
					<thead>
						<th scope="col" style="width: auto;">#</th>
					    <th scope="col" style="width: auto;">Model</th>
				      	<th scope="col" style="width: auto;">IMEI</th>
					</thead>
					<tbody class="tbody">
					<?php if ($this->data['phones'][0]->id != null):
					foreach ($this->data['phones'] as $key => $phone) {
					?>
					<tr style="cursor: pointer;" onclick="document.location.href='<?php echo INCL_PATH.'Phones/'.$phone->id; ?>'">
						<th scope="row"><?php echo $key + 1; ?></th>
						<td><?php echo $phone->model; ?></td>
						<td><?php echo $phone->imei; ?></td>
					</tr>
					<?php
					}
					else: ?>
					<tr><td colspan="6">Nema napravljenih terminala.</td></tr>
					<?php endif ?>
					</tbody>
				</table>