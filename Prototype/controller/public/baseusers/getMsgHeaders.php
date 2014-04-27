<?php
require_once("../validate_has_vars.php");
require_once("baseusers.inc.php");

require_once("check_login.php");

$bu = new BaseUsers();
print(json_encode($bu->getMsgHeaders($vars->name,$vars->password,$vars->start,$vars->end)));
?>