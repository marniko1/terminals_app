		<div class="container">
			<div class="row">
				<div class="form-wrapper col-5">
					<form class="mt-5 col-12" method="post" action="<?php echo INCL_PATH.'Admin/addNewUser';?>" id="new-user">
						<h5>Add new user</h5>
						<div class="form-group">
							<label for="username">Username: </label>
							<input type="text" name="username" id="username" class="form-control">
						</div>
						<div class="form-group">
							<label for="password">Password: </label>
							<input type="password" name="password" id="password" class="form-control">
						</div>
						<div class="form-group">
							<label for="co_password">Confirm Password: </label>
							<input type="password" name="co_password" id="co_password" class="form-control">
						</div>
						<div class="form-group">
							<input type="checkbox" name="priviledge" id="priviledge" class="form-check-input ml-2" value="2">
							<label for="priviledge" class="form-check-label ml-4">Admin priviledge</label>
						</div>
						<div class="form-group">
							<input type="submit" value="Submit" class="btn btn-primary submit submit_btn">
						</div>
					</form>
					<span class="msg-span"><?php echo (isset($this->data['msg']['msg1'])) ? $this->data['msg']['msg1'] : false ?></span>
				</div>
				<div class="list-of-users-wrapper mt-5 col-7">
					<h5>All users list</h5>
					<div class="inner-list-of-users-wrapper col-12 border">
						<form method="post" action="<?php echo INCL_PATH.'Admin/removeUser';?>" class="edit_form">
							<table class="table table-sm mt-1 main">
								<thead class="thead-light">
								    <tr>
								      <th scope="col" style="width: 5%">#</th>
								      <th scope="col" style="width: 20%">Username</th>
								      <th scope="col" style="width: 10%">Password</th>
								      <th scope="col" style="width: 10%">Priviledge</th>
								      <th scope="col" style="width: 30%"></th>
								    </tr>
								</thead>
								<tbody class="tbody col-12">
									<?php
									foreach ($this->data['users'] as $key => $user) {
									?>
										<tr>
									      <th scope="col"><?php echo $key + 1; ?></th>
									      <td data-name="edit_username"><?php echo $user->username; ?></td>
									      <td data-name="edit_password"><?php echo $user->password; ?></td>
									      <td data-name="edit_priviledge"><?php echo $user->priviledge; ?></td>
									      <th><input type="hidden" name="user_id" value="<?php echo $user->id; ?>" disabled><div class="btn-holder"><input type="button" name="edit" value="Edit" class="btn btn-sm btn-info edit" disabled><input type="submit" name="remove" value="Remove" class="btn btn-sm ml-1 btn-danger remove"></div></th>
									    </tr>
									<?php
									}
									?>
								</tbody>
							</table>
						</form>
					</div>
				</div>