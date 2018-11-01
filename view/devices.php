		<div class="container">
			<div class="row">
				<h1>DEVICES</h1>
				<form class="mt-2 col-12 mb-5">
					<div class="form-group">
						<input type="text" name="filter" placeholder="Filter" id="filter">
					</div>
					<div class="mt-2 row">
						<div class="form-group form-group-inline col-2">
					      	<select id="inputState" class="form-control" name="type">
					        	<option value="/">Tip...</option>
					        	<option value="pda">PDA</option>
					        	<option value="printer">Štampač</option>
					      	</select>
					    </div>
						<div class="form-group form-group-inline col-2">
					      	<select id="inputState" class="form-control" name="model">
					        	<option value="/">Model...</option>
					        	<option value="">...</option>
					      	</select>
					    </div>
					    <div class="form-group form-group-inline col-2">
					      	<select id="inputState" class="form-control" name="location">
					        	<option value="/">Lokacija...</option>
					        	<option value="">...</option>
					      	</select>
					    </div>
					    <div class="form-group form-group-inline col-2">
					      	<select id="inputState" class="form-control" name="software_v">
					        	<option value="/">Software v...</option>
					        	<option value="">...</option>
					      	</select>
					    </div>
					    <div class="form-check form-check-inline">
					    	<input type="hidden" name="discharged" value="0">
					      	<input class="form-check-input" type="checkbox" id="discharged" name="discharged" value="1">
					      	<label class="form-check-label" for="discharged">
					        	Otpisan
					      	</label>
					    </div>
					</div>
				</form>
				<?php
				// var_dump($this->data['devices']);
				?>
				<div  class="table-holder" style="min-height: 450px; width:100%">
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
				</div>
				<nav class="col-12">
				    <ul class="pagination justify-content-center">
				    	<?php
					    foreach ($this->data['pagination_links'] as $link) {
					    	echo  '<li class="page-item"><a href="'.$link[0].'" class="page-link">'.$link[1].'</a></li>';
					    }
					    ?>
				    </ul>
				</nav>