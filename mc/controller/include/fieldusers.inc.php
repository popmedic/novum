<?php
require_once("db.inc.php");

class FieldUsers extends Db{
    private function findUserId($name, $phone_number, $agency, $unit, $ip_addr, $mac_addr, $ui){
        $sql = "SELECT id FROM field_users WHERE name = ? AND phone_number = ? AND agency = ? AND ".
                                                "unit = ? AND ip_addr = ? AND mac_addr = ? AND  ui = ?;";
        $res = $this->query($sql, array($name, $phone_number, $agency, $unit, $ip_addr, $mac_addr, $ui));
        if(!NMError::is_error($res)){
            if(count($res['rows']) > 0){
                return $res['rows'][0]['id'];
            }
            else{
                $sql = "INSERT INTO `field_users`(`name`, `phone_number`, `agency`, `unit`, `ip_addr`, `mac_addr`, `ui`) ".
                       "VALUES (?, ?, ?, ?, ?, ?, ?);";
                //printf(str_replace("?", "\"%s\"", $sql), $name, $phone_number, $agency, $unit, $ip_addr, $mac_addr, $ui); 
                $res = $this->query($sql, array($name, $phone_number, $agency, $unit, $ip_addr, $mac_addr, $ui));
                
                if(!NMError::is_error($res)){
                    $sql =  "SELECT `id` FROM `field_users` WHERE `name` = ? AND `phone_number` = ? AND `agency` = ? AND ".
                            "`unit` = ? AND `ip_addr` = ? AND `mac_addr` = ? AND  `ui` = ?;";
                    $res = $this->query($sql,array($name, $phone_number, $agency, $unit, $ip_addr, $mac_addr, $ui));
                    //print("<pre>".json_encode($res)."</pre>");
                    if(!NMError::is_error($res)){
                        if(count($res['rows']) > 0){
                            return $res['rows'][0]['id'];
                        }
                        else{
                            print(json_encode(NMError::error("FATAL ERROR: unable to find field user.")));
                            exit();
                        }
                    }
                    else{
                        print(json_encode(NMError::get_error($res)));
                        exit();
                    }
                }
                else{
                    print(json_encode(NMError::get_error($res)));
                    exit();
                }
            }
        }
        else{
            print(json_encode(NMError::get_error($res)));
            exit();
        }
                
    }
    public function sendMessage($name, $phone_number, $agency, $unit, $ip_addr, $mac_addr, $ui, $toid, $message){
        $fid = $this->findUserId($name, $phone_number, $agency, $unit, $ip_addr, $mac_addr, $ui);
        $sql = "INSERT INTO `base_messages`(`from`, `to`, `message`) VALUES (?, ? , ?);";
        $res = $this->query($sql, array($fid, $toid, $message));
        if(!NMError::is_error($res)){
            $sql = "SELECT `id` FROM `base_messages` WHERE `from` = ? AND `to` = ? AND `message` = ? ORDER BY `id`;";
            $res = $this->query($sql, array($fid, $toid, $message));
            if(!NMError::is_error($res)){
                if(count($res["rows"]) > 0){
                    $mid = $res["rows"][count($res["rows"])-1]["id"];
                    return NMError::id_success($mid);
                }
                else{
                    return NMError::error("UNABLE TO FIND NEW MESSAGE ID");
                }
            }
        }
        return $res;
    }
    public function addAttachment($message_id, $data, $type){
        $sql = "INSERT INTO `base_attachments`(`message`, `data`, `type`) VALUES (?, ?, ?);";
        $res = $this->query($sql, array($message_id, $data, $type));
        return $res;
    }
}
?>