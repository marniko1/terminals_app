		<div class="container">
			<div class="row">
				<nav class="navbar col-12 row">
					<ul class="nav col-12 justify-content-center">
						<li class="nav-item border-right"><a class="nav-link" href="<?php echo INCL_PATH.'Terminals/index';?>">Lista terminala</a></li>
						<li class="nav-item"><a class="nav-link" id="page_2_link" href="<?php echo INCL_PATH.'Terminals/panel';?>">Sastavi terminal</a></li>
					</ul>
				</nav>
				<form class="mt-2 col-12 mb-5">
					<input type="text" name="filter" placeholder="Filter" id="filter">
					<div class="mt-2 row params">
						<div class="form-group form-group-inline col-2">
					      	<select id="location" class="form-control" name="location">
					        	<option value="">Lokacija...</option>
					        	<option value="1">magacin</option>
					        	<option value="3">kontrola</option>
					        	}
					        	?>
					      	</select>
					    </div>
					</div>
				</form>
				<div  class="table-holder" style="min-height: 450px; width:100%">
					<table class="col-12 table table-sm">
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
					<?php if ($this->data['terminals'][0]->terminal_num != null):
						foreach ($this->data['terminals'] as $key => $terminal) {
					?>
							<tr style="cursor: pointer;" onclick="document.location.href='<?php echo INCL_PATH.'Terminals/'.$terminal->id; ?>'">
								<th scope="row"><?php echo $key + 1; ?></th>
								<td><?php echo $terminal->terminal_num; ?></td>
								<td><?php echo $terminal->pda_sn; ?></td>
								<td><?php echo $terminal->pda_nav_num; ?></td>
								<td><?php echo $terminal->printer_sn; ?></td>
								<td><?php echo $terminal->printer_nav_num; ?></td>
								<td><?php echo $terminal->num; ?></td>
								<td><?php echo $terminal->iccid; ?></td>
								<td><?php echo $terminal->location; ?></td>
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