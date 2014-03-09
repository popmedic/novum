<?php
$homedir = trim(`cd ~ && pwd`);
$path = $homedir.'/php/include';
set_include_path(get_include_path() . PATH_SEPARATOR . $path);
?>