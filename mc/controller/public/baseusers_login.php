<?php
require_once("validate_has_vars.php");
require_once("baseusers.inc.php");

if(!isset($vars->name)){
    print(json_encode(NMError::error("name var must be set")));
    exit();
}
if(!isset($vars->password)){
    print(json_encode(NMError::error("password var must be set")));
    exit();
}

$bu = new BaseUsers();
print(json_encode($bu->login($vars->name,$vars->password)));
?>