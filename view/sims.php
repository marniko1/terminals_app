		<div class="container">
			<div class="row">
				<h1>SIMs</h1>
				<?php
				// var_dump($this->data['sim_cards']);
				?>
				<nav class="navbar col-12 row">
					<ul class="nav col-12 justify-content-center">
						<li class="nav-item border-right"><a class="nav-link" href="<?php echo INCL_PATH.'SIMs/index';?>">Lista sim kartica</a></li>
						<li class="nav-item border-right"><a class="nav-link" id="page_2_link" href="<?php echo INCL_PATH.'SIMs/panel';?>">Dodaj novi sim</a></li>
						<li class="nav-item"><a class="nav-link" id="page_2_link" href="<?php echo INCL_PATH.'SIMs/charge';?>">Zaduženje</a></li>
					</ul>
				</nav>
				<form class="mt-2 col-12 mb-5">
					<input type="text" name="filter" placeholder="Filter" id="filter">
				</form>
				<div  class="table-holder" style="min-height: 450px; width:100%">
					<table class="col-12 table table-sm">
						<caption>Lista sim kartica</caption>
						<thead>
							<th scope="col" style="width: auto;">#</th>
						    <th scope="col" style="width: auto;">Broj</th>
					      	<th scope="col" style="width: auto;">ICCID</th>
					      	<th scope="col" style="width: auto;">Namena</th>
						</thead>
						<tbody class="tbody">
					<?php if ($this->data['sim_cards'][0]->id != null):
						foreach ($this->data['sim_cards'] as $key => $sim) {
						?>
							<tr style="cursor: pointer;" onclick="document.location.href='<?php echo INCL_PATH.'SIMs/'.$sim->id; ?>'">
								<th scope="row"><?php echo $key + 1; ?></th>
								<td><?php echo '+' . $sim->network . '/' . $sim->num; ?></td>
								<td><?php echo $sim->iccid; ?></td>
								<td><?php echo $sim->purpose; ?></td>
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