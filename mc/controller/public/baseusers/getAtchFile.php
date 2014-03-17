<?php
require_once("../validate_has_vars.php");
require_once("baseusers.inc.php");

require_once("check_login.php");

if(!isset($vars->id)){
    print(json_encode(NMError::error("id var must be set")));
    exit();
}

$bu = new BaseUsers();
$res = $bu->getAtchData($vars->name,$vars->password,$vars->id);
if(!NMError::is_error($res)){
    $data = $res['data'];//NMError::get_data($res);
    $type = $res['type'];//NMError::get_type($res);
    
    if(isset($vars->thumb)){
        $img = imagecreatefromstring($data);
        $w = imagesx($img);
		$h = imagesy($img);
		$nh = 120;
		$nw = floor($w * ($nh/$h));
		$ti = imagecreatetruecolor($nw, $nh);
		imagecopyresized($ti, $img, 0, 0, 0, 0, $nw, $nh, $w, $h) ;
        header("Content-type: image/jpeg");
        imagejpeg($ti);
    }
    else{
        header("Content-type: ".$type);
        print($data);
    }
}
?>