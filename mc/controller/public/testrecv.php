<html>
    <head>
        <script src="http://code.jquery.com/jquery-1.11.0.min.js"></script>
        <script src="http://code.jquery.com/jquery-migrate-1.2.1.min.js"></script>
        <style>
            body{
                font-family: 'Gill Sans', Arial, Helvetica;
            }
        </style>
    </head>
    <body>
<?php
require_once('relate_include_path.php');
require_once('baseusers.inc.php');
require_once('fieldusers.inc.php');

$name = 'novumroot';
$pass = '5414a00ad69c1584167389e5640fe1b0';

$bus = new BaseUsers;

$dt1 = new DateTime();
$dt2 = new DateTime();
$dt1->sub(new DateInterval('PT1H'));

$res = $bus->getMsgHeaders($name, 
                           $pass, 
                           $dt1->format('Y-m-d H:i:s.u'), 
                           $dt2->format('Y-m-d H:i:s.u'));
for($i = 0; $i < count($res["rows"]); $i++){
    $msg = $bus->readMessage($name, $pass, $res["rows"][$i]["id"]);
?>
<div>From: 
    <blockquote>
        <div>Name: <?php print($msg["rows"][0]['fname']); ?></div>
        <div>Phone: <?php print($msg["rows"][0]['fphone_number']); ?></div>
        <div>Agency: <?php print($msg["rows"][0]['fagency']); ?></div>
        <div>Phone: <?php print($msg["rows"][0]['funit']); ?></div>
        <div>IP Address: <?php print($msg["rows"][0]['fip_addr']); ?></div>
    </blockquote>
    <div>On: <?php print($msg["rows"][0]['sentts']); ?></div>
    <div>Read: <?php print($msg["rows"][0]['read']); ?></div>
</div>
<div>Message:
    <blockquote>
        <?php print($msg["rows"][0]['message']); ?>
    </blockquote>
</div>
<div>Attachments:
    <blockquote>
<?php
    $atchs = $bus->getAtchHeaders($name, $pass, $res["rows"][$i]["id"]);
    if(!NMError::is_error($atchs)){
        if(count($atchs['rows']) == 0){
            print("NONE<p></p>");
        }
        else{
            for($i2 = 0; $i2 < count($atchs['rows']); $i2++)
            {
                $aid = $atchs['rows'][$i2]['id'];
                $type = $atchs['rows'][$i2]['type'];
                print("<a href='http://kevinscardina.com/novum/mc/api/public/baseusers/getAtchFile.php?vars=".
                      preg_replace("/[\n\r]/", " ", preg_replace("/\"/", '"', 
                                                                 json_encode(array("name" => $name, "password" => $pass, "id" => $aid)))).
                      "'><img src='http://kevinscardina.com/novum/mc/api/public/baseusers/getAtchFile.php?vars=".
                      preg_replace("/[\n\r]/", " ", preg_replace("/\"/", '"', 
                                                                 json_encode(array("name" => $name, "password" => $pass, "id" => $aid)))).
                      "' width=\"128px\" /></a>");
            }
        }
    }
?>
    </blockquote>
</div> 
<hr/>
<?php
}
?>
    </body>
</html>