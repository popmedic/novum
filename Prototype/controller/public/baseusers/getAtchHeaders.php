<?php
require_once("../validate_has_vars.php");
require_once("baseusers.inc.php");

require_once("check_login.php");

if(!isset($vars->message_id)){
    print(json_encode(NMError::error("message_id var must be set")));
    exit();
}

$bu = new BaseUsers();
print(json_encode($bu->getAtchHeaders($vars->name,$vars->password,$vars->message_id)));
?>