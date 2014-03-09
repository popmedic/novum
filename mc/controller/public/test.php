<?php
require_once('relate_include_path.php');
require_once('baseusers.inc.php');
$name = 'novumroot';
$pass = '5414a00ad69c1584167389e5640fe1b0';
$bus = new BaseUsers;
$res = $bus->login($name, $pass);
print(json_encode($res));
print("<p></p>");
$res = $bus->checkForMessages($name, $pass);
print(json_encode($res));
print("<p></p>");
?>