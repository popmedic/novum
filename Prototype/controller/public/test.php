<?php
require_once('relate_include_path.php');
require_once('baseusers.inc.php');
require_once('fieldusers.inc.php');
//print("<pre>".str_replace(',',",\n", json_encode($_SERVER))."</pre>");
$name = 'novumroot';
$pass = '5414a00ad69c1584167389e5640fe1b0';
$ip = $_SERVER['REMOTE_ADDR'];
$fus = new FieldUsers;
$res = $fus->sendMessage("Novum Field Cliet", "0", "NovumFC", "909", $ip, '0', 1, 1, "This is a test");
print("Sent Message to id=1:<p></p><pre>".str_replace(',',",\n\t", json_encode($res))."</pre>");
$bus = new BaseUsers;
$res = $bus->login($name, $pass);
print("Login as novumroot:<p></p><pre>".str_replace(',',",\n\t", json_encode($res))."</pre>");
print("<p></p>");
sleep(2);
$res = $bus->getMsgHeaders($name, $pass);
print("getMsgHeaders for novumroot:<p></p><pre>".str_replace(',',",\n\t", json_encode($res))."</pre>");
print("<p></p>");
$res = $bus->checkMsgHeaders($name, $pass);
print("checkMsgHeaders for novumroot:<p></p><pre>".str_replace(',',",\n\t", json_encode($res))."</pre>");
print("<p></p>");
$dt1 = new DateTime();
$dt2 = new DateTime();
$dt1->sub(new DateInterval('PT10M'));

$res = $bus->getMsgHeaders($name, 
                           $pass, 
                           $dt1->format('Y-m-d H:i:s.u'), 
                           $dt2->format('Y-m-d H:i:s.u'));
print("getMsgHeaders for novumroot from ".
      $dt1->format('Y-m-d H:i:s.u').
      " to ".$dt2->format('Y-m-d H:i:s.u').":<p></p><pre>".
      str_replace(',',",\n\t", json_encode($res))."</pre>");
print("<p></p>");
print("now get the last 10 minutes of messages:<p></p><blockqoute>");
for($i = 0; $i < count($res["rows"]); $i++){
    $msg = $bus->readMessage($name, $pass, $res["rows"][$i]["id"]);
    print("<pre>".str_replace(',',",\n\t", json_encode($msg))."</pre><p></p>");
    print("Check for Attachments:");
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
                      preg_replace("/[\n\r]/", " ", preg_replace("/\"/", '"', json_encode(array("name" => $name, "password" => $pass, "id" => $aid)))).
                      "'>Attachment ".(string)$i2.": ".$type."</a>");
            }
        }
    }
}
print("</blockqoute><p></p>");
?>