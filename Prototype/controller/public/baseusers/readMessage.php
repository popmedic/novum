<?php
require_once("../validate_has_vars.php");
require_once("baseusers.inc.php");

require_once("check_login.php");

if(!isset($vars->id)){
    print(json_encode(NMError::error("id var must be set")));
    exit();
}

$bu = new BaseUsers();
print(json_encode($bu->readMessage($vars->name,$vars->password,$vars->id)));
?>