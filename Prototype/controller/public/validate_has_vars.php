<?php
require_once("relate_include_path.php");
require_once("nmerror.inc.php");
require_once("dbg_out.inc.php");

if(!isset($_REQUEST['vars'])){
    print(json_encode(NMError::error("vars must be set")));
    exit();
}
$vars = json_decode($_REQUEST['vars']);
?>