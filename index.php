<?php

session_start();


include 'config/php_path/path.php';
// include 'config/pagination_setup/pagination_setup.php';

require_once 'core/ClassAutoloader/ClassAutoLoader.php';

new ClassAutoLoader('core');
new ClassAutoLoader('model');

include 'controller/BaseController.php';
include 'routes.php';