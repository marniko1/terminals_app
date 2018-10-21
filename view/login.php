		<div class="container">
			<div class="row">
				<form class="col-sm-4 offset-sm-4 mt-5" method="post" action="<?php echo INCL_PATH.'Login/loginUser'; ?>">
					<div class="form-group">
						<label for="username">Username: </label>
						<input type="text" name="username" id="username" class="form-control">
					</div>
					<div class="form-group">
						<label for="password">Password: </label>
						<input type="password" name="password" id="password" class="form-control">
						
					</div>
					<div class="form-group">
						<input type="submit" name="submit" value="Login" class="btn btn-primary">
					</div>
					<?php echo (isset($this->data['msg']['msg1'])) ? "<span class='text-danger'>" . $this->data['msg']['msg1'] . "</span>" : false ?>
				</form>