		<div class="container">
			<div class="row">
				<nav class="navbar col-12 row">
					<ul class="nav col-12 justify-content-center">
						<li class="nav-item border-right"><a class="nav-link" href="<?php echo INCL_PATH.'Devices/index';?>">Lista uređaja</a></li>
						<li class="nav-item"><a class="nav-link" id="page_2_link" href="<?php echo INCL_PATH.'Devices/panel';?>">Lokacije</a></li>
					</ul>
				</nav>
				<form class="mt-2 col-12 mb-5">
					<div class="form-group">
						<input type="text" name="filter" placeholder="Filter" id="filter">
					</div>
					<div class="mt-2 row params">
						<div class="form-group form-group-inline col-2">
					      	<select id="type" class="form-control" name="type">
					        	<option value="">Tip...</option>
					        	<?php
					        	foreach ($this->data['types'] as $type) {
					        	?>
					        	<option value="<?php echo $type->id; ?>"><?php echo $type->title; ?></option>
					        	<?php
					        	}
					        	?>
					      	</select>
					    </div>
						<div class="form-group form-group-inline col-2">
					      	<select id="model" class="form-control" name="model">
					        	<option value="">Model...</option>
					        	<?php
					        	foreach ($this->data['models'] as $model) {
					        	?>
					        	<option value="<?php echo $model->id; ?>"><?php echo $model->title; ?></option>
					        	<?php
					        	}
					        	?>
					      	</select>
					    </div>
					    <div class="form-group form-group-inline col-2">
					      	<select id="location" class="form-control" name="location">
					        	<option value="">Lokacija...</option>
					        	<?php
					        	foreach ($this->data['locations'] as $location) {
					        	?>
					        		<option value="<?php echo $location->id; ?>"><?php echo $location->title; ?></option>
					        	<?php
					        	}
					        	?>
					      	</select>
					    </div>
					    <div class="form-group form-group-inline col-2">
					      	<select id="software_v" class="form-control" name="software_v">
					        	<option value="">Software v...</option>
					        	<?php
					        	foreach ($this->data['software_v'] as $software_v) {
					        	?>
					        		<option value="<?php echo $software_v->id; ?>"><?php echo $software_v->software; ?></option>
					        	<?php
					        	}
					        	?>
					      	</select>
					    </div>
					    <div class="form-group form-group-inline col-2">
					      	<select id="active" class="form-control" name="active">
					        	<option value="">Status...</option>
					        	<option value="1">aktivni</option>
					        	<option value="2">otpisan</option>
					      	</select>
					    </div>
					</div>
				</form>
				<div  class="table-holder" style="min-height: 450px; width:100%">
					<table class="col-12 table table-sm">
						<caption>Lista uređaja</caption>
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
						<tr><td colspan="6">Nema napravljenih uređaja.</td></tr>
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