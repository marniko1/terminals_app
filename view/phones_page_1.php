		<div class="container">
			<div class="row">
				<nav class="navbar col-12 row">
					<ul class="nav col-12 justify-content-center">
						<li class="nav-item border-right"><a class="nav-link" href="<?php echo INCL_PATH.'Phones/index';?>">Lista telefona</a></li>
						<li class="nav-item"><a class="nav-link" id="page_2_link" href="<?php echo INCL_PATH.'Phones/panel';?>">Dodaj novi telefon</a></li>
					</ul>
				</nav>
				<form class="mt-2 col-12 mb-5">
					<input type="text" name="filter" placeholder="Filter" id="filter">
				</form>
				<div  class="table-holder" style="min-height: 450px; width:100%">
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
							<th scope="row"><?php echo $key + 1 + $this->skip; ?></th>
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