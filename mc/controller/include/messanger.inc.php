<?php
require_once 'db.inc.php';

class Messanger extends Db{
    function getLastCheckedForId($id){
        try{
            $sql = 'select last_checked from clients where id = ?;';
            $stmt = $this->db->prepare($sql);
            $stmt->execute(array($id));
            $row = $stmt->fetch(PDO::FETCH_NUM);
            return $row[0];
        }
        catch (PDOException $e) {
            return(array("ERROR" => $e->getMessage()));
        }  
    }
    function checkMessagesForId($id){
        try{
            $ct = $this->getCurrentTimestamp();
            $ssql = 'select * from messages where to_id = ? and time_stamp >= (select last_checked from clients where id = ?) and time_stamp < ?;';
            //printf(str_replace('?', "'%s'", $ssql)."<br/>", $id, $id, $ct);
            $sstmt = $this->db->prepare($ssql);
            $usql = 'update clients set last_checked = ? where id = ?;';
            $ustmt = $this->db->prepare($usql);
            $sstmt->execute(array($id, $id, $ct));
            $ustmt->execute(array($ct, $id));
            if($sstmt->rowCount() < 1){
                return array("SUCCESS" => 0);
            }
            else{
                $rtn = array();
                while($row = $sstmt->fetch(PDO::FETCH_ASSOC)){
                    array_push($rtn, $row);
                }
                return array("SUCCESS" => $rtn);
            } 
        }
        catch (PDOException $e) {
            return(array("ERROR" => $e->getMessage()));
        }
    }
    function sendMessage($from_id, $to_id, $message){
        try{
            $sql = 'insert into messages (from_id, to_id, message) values (?, ? , ?);';
            $stmt = $this->db->prepare($sql);
            $res = $stmt->execute(array($from_id, $to_id, $message));
            return array("SUCCESS" => $res);
        }
        catch (PDOException $e) {
            return(array("ERROR" => $e->getMessage()));
        }
    }
}/*
$m = new Messanger();
print_r($m->sendMessage(51, 52, "nother testy"));
print_r($m->sendMessage(51, 52, "nother testy 2"));
print_r($m->checkMessagesForId(52));*/
?>