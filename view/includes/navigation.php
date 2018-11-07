<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="collapse navbar-collapse">
	    <div class="navbar-header">
	      <a class="navbar-brand" href="<?php echo INCL_PATH; ?>">Terminals App</a>
	    </div>
	    <ul class="nav navbar-nav ml-5">
	      <li class="nav-item"><a href="<?php echo INCL_PATH; ?>"  class="nav-link">Home</a></li>
	      <li class="nav-item"><a href="<?php echo INCL_PATH . 'Terminals/index'; ?>"  class="nav-link">Terminali</a></li>
	      <li class="nav-item"><a href="<?php echo INCL_PATH  . 'Devices/index'; ?>"  class="nav-link">Uređaji</a></li>
	      <li class="nav-item"><a href="<?php echo INCL_PATH  . 'SIMs/index'; ?>"  class="nav-link">SIM</a></li>
	      <li class="nav-item"><a href="<?php echo INCL_PATH  . 'Phones/index'; ?>"  class="nav-link">Telefoni</a></li>
	      <li class="nav-item"><a href="<?php echo INCL_PATH  . 'Agents/index'; ?>"  class="nav-link">Kontrolori</a></li>
	      <li class="nav-item"><a href="<?php echo INCL_PATH  . 'Charges/index'; ?>"  class="nav-link">Zaduženja</a></li>
	      <li class="nav-item"><a href="<?php echo INCL_PATH  . 'Service/index'; ?>"  class="nav-link">Servis</a></li>
	      <?php 
	      echo (Auth::admin()) ? '<li class="nav-item"><a href="'.INCL_PATH.'Admin/index" class="nav-link">Admin</a></li>' : false 
	      ?>
	    </ul>
  	</div>
  	<form method="post" action="<?php echo INCL_PATH.'Login/logoutUser'; ?>">
		<div class="form-group">
   			<button class="btn btn-danger navbar-btn float-right">Logout</button>
   		</div>
	</form>
</nav>