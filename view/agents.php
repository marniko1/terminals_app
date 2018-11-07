		<div class="container">
			<div class="row">
				<form class="mt-2 col-12 mb-5">
					<input type="text" name="filter" placeholder="Filter" id="filter">
				</form>
				<div  class="table-holder" style="min-height: 450px; width:100%">
					<table class="col-12 table table-sm">
						<caption>Lista kontrolora</caption>
						<thead>
							<th scope="col" style="width: auto;">#</th>
						    <th scope="col" style="width: auto;">Kontrolor</th>
					      	<th scope="col" style="width: auto;">Broj služb. leg.</th>
					      	<th scope="col" style="width: auto;">Službeni telefon</th>
					      	<th scope="col" style="width: auto;">Terminal</th>
						</thead>
						<tbody class="tbody">
						<?php if ($this->data['agents'][0]->agent != null):
						foreach ($this->data['agents'] as $key => $agent) {
						?>
						<tr style="cursor: pointer;" onclick="document.location.href='<?php echo INCL_PATH.'Agents/'.$agent->single_agent_id; ?>'">
							<th scope="row"><?php echo $key + 1; ?></th>
							<td><?php echo $agent->agent; ?></td>
							<td><?php echo $agent->off_num; ?></td>
							<td><?php echo $agent->agent_sim_num; ?></td>
							<td><?php echo $agent->terminal_num; ?></td>
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