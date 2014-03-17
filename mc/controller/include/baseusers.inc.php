<?php
require_once('db.inc.php');
$homedir = trim(`cd ~ && pwd`);
$logfile = fopen($homedir."/log/baseuser-out.log", "a+");
class BaseUsers extends Db {
    public function is_login($name, $password){
        $sql = "select * from base_users where name = ? and password = ?;";
        $res = $this->query($sql, array($name, $password));
        if(!NMError::is_error($res)){
            if(count($res['rows']) == 0){
                return false;  
            }
            return true;
        }
        return false;
    }
    public function login($name, $password){
        $sql = "select * from base_users where name = ? and password = ?;";
        $res = $this->query($sql, array($name, $password));
        if(!NMError::is_error($res)){
            if(count($res['rows']) == 0){
                return NMError::error($name." with password does not exist!");  
            }
            return NMError::id_success($res['rows'][0]["id"]);
        }
        return $res;
    }
    private function getChecked($buid){
        $res = $this->query("SELECT checked FROM base_users WHERE id = ?", array($buid));
        if(!NMError::is_error($res)){
            if($res['rows'][0]['checked'] != null){
                return new DateTime($res['rows'][0]['checked']);
            }
        }
        return $this->getPreDate();
    }
    public function getMsgHeaders($name, $password, $start=null, $end=null){
        global $logfile;
        $res = $this->login($name, $password);
        if(!NMError::is_error($res)){
            $buid = NMError::get_id($res);
            $sql = "SELECT ".
                   " `base_messages`.`id` AS `id`, ".
                   " `field_users`.`id` AS `fid`, ".
                   " `field_users`.`name` AS `fname`, ".
                   " `field_users`.`phone_number` AS `fphone_number`, ".
                   " `field_users`.`agency` AS `fagency`, ".
                   " `field_users`.`unit` AS `funit`, ".
                   " `field_users`.`ip_addr` AS `fip_addr`, ".
                   " `field_users`.`mac_addr` AS `fmac_addr`, ".
                   " `field_users`.`ui` AS `fuiid`, ".
                   " `base_users`.`id` AS `tid`, ".
                   " `base_users`.`name` AS `tname`, ".
                   " `base_users`.`customer` AS `tcustid`, ".
                   " `base_users`.`pubkey` AS `tpubkey`, ".
                   " `base_users`.`ui` AS `tuiid`, ".
                   " `base_users`.`checked` AS `tchecked`, ".
                   " `base_messages`.`ts` AS `sentts`, ".
                   " `base_messages`.`read` AS `read` ".
                   "FROM ".
                   " `field_users`, ".
                   " `base_users`, ".
                   " `base_messages` ".
                   " WHERE ".
                   " `field_users`.`id` = `base_messages`.`from` and ".
                   " `base_users`.`id` = `base_messages`.`to` and ".
                   " `base_messages`.`ts` > ? and ".
                   " `base_messages`.`ts` <= ? and ".
                   " `base_messages`.`to` = ? ".
                   "ORDER BY `id` DESC;";
            $dts = null;
            $dte = null;
            
            if($start == null){
                $start = $this->getPreDate()->format('Y-m-d H:i:s.u');
            }
            
            if($end == null){
                $dte = new DateTime;
                $end = $dte->format('Y-m-d H:i:s.u');
            }
            
            fprintf($logfile, str_replace("?","\"%s\"", $sql."\n"), $start, $end, $buid);
            
            $res = $this->query($sql, array($start, $end, $buid));
            /*if($start == null){
                $dts = $this->getPreDate();
            }
            else{
                $dts = DateTime::createFromFormat('Y-m-d H:i:s O', $start);
            }
            if($dts == null) {
                fprintf($logfile, "Unable to create dts from : %s\r\n", $start);
                $dts = $this->getPreDate();
            }
            
            if($end == null){
                $nc = true;
                $dte = new DateTime;
            }
            else{
                $dte = DateTime::createFromFormat('Y-m-d H:i:s O', $end);
            }
            if($dte == null){
                fprintf($logfile, "Unable to create dte from : %s\r\n", $end);
                $dte = new DateTime;
            } 
            
            fprintf($logfile, str_replace("?","\"%s\"", $sql."\n"), $dts->format('Y-m-d H:i:s.u'), $dte->format('Y-m-d H:i:s.u'), $buid);
            
            $res = $this->query($sql, array($dts->format('Y-m-d H:i:s.u'), $dte->format('Y-m-d H:i:s.u'), $buid));*/
        }
        return $res;
    }
    public function checkMsgHeaders($name, $password, $start=null, $end=null){
        $res = $this->login($name, $password);
        if(!NMError::is_error($res)){
            $buid = NMError::get_id($res);
            $sql = "SELECT ".
                   " `base_messages`.`id` AS `id`, ".
                   " `field_users`.`id` AS `fid`, ".
                   " `field_users`.`name` AS `fname`, ".
                   " `field_users`.`phone_number` AS `fphone_number`, ".
                   " `field_users`.`agency` AS `fagency`, ".
                   " `field_users`.`unit` AS `funit`, ".
                   " `field_users`.`ip_addr` AS `fip_addr`, ".
                   " `field_users`.`mac_addr` AS `fmac_addr`, ".
                   " `base_users`.`id` AS `tid`, ".
                   " `base_users`.`name` AS `tname`, ".
                   " `base_users`.`customer` AS `tcustid`, ".
                   " `base_users`.`pubkey` AS `tpubkey`, ".
                   " `base_users`.`ui` AS `tuiid`, ".
                   " `base_users`.`checked` AS `tchecked`, ".
                   " `base_messages`.`ts` AS `sentts` , ".
                   " `base_messages`.`read` AS `read` ".
                   "FROM ".
                   " `field_users`, ".
                   " `base_users`, ".
                   " `base_messages` ".
                   " WHERE ".
                   " `field_users`.`id` = `base_messages`.`from` and ".
                   " `base_users`.`id` = `base_messages`.`to` and ".
                   " `base_messages`.`ts` > ? and ".
                   " `base_messages`.`ts` <= ? and ".
                   " `base_messages`.`to` = ? ".
                   "ORDER BY `id` DESC;";
            $dts = null;
            $dte = null;
            $nc = false;
            
            $dts = $this->getChecked($buid);
            $dte = new DateTime;
            
            //printf(str_replace("?","\"%s\"", $sql."<p></p>"), $dts->format('Y-m-d H:i:s.u'), $dte->format('Y-m-d H:i:s.u'), $buid);
            
            $res = $this->query($sql, array($dts->format('Y-m-d H:i:s.u'), $dte->format('Y-m-d H:i:s.u'), $buid));
            $this->query("UPDATE `base_users` SET `checked` = ? WHERE `id` = ?;", array($dte->format('Y-m-d H:i:s.u'), $buid));
        }
        return $res;
    }
    public function readMessage($name, $password, $id){
        $res = $this->login($name, $password);
        if(!NMError::is_error($res)){
            $buid = NMError::get_id($res);
            $sql = "SELECT ".
                   " `base_messages`.`id` AS `id`, ".
                   " `field_users`.`id` AS `fid`, ".
                   " `field_users`.`name` AS `fname`, ".
                   " `field_users`.`phone_number` AS `fphone_number`, ".
                   " `field_users`.`agency` AS `fagency`, ".
                   " `field_users`.`unit` AS `funit`, ".
                   " `field_users`.`ip_addr` AS `fip_addr`, ".
                   " `field_users`.`mac_addr` AS `fmac_addr`, ".
                   " `base_users`.`id` AS `tid`, ".
                   " `base_users`.`name` AS `tname`, ".
                   " `base_users`.`customer` AS `tcustid`, ".
                   " `base_users`.`pubkey` AS `tpubkey`, ".
                   " `base_users`.`ui` AS `tuiid`, ".
                   " `base_users`.`checked` AS `tchecked`, ".
                   " `base_messages`.`ts` AS `sentts` , ".
                   " `base_messages`.`read` AS `read`, ".
                   " `base_messages`.`message` AS `message` ".
                   "FROM ".
                   " `field_users`, ".
                   " `base_users`, ".
                   " `base_messages` ".
                   " WHERE ".
                   " `field_users`.`id` = `base_messages`.`from` and ".
                   " `base_users`.`id` = `base_messages`.`to` and ".
                   " `base_messages`.`id` = ? AND".
                   " `base_messages`.`to` = ? ".
                   "ORDER BY `id` DESC;";
            //printf(str_replace("?","\"%s\"", $sql."<p></p>"), $id, $buid);
            $res = $this->query($sql, array($id, $buid));
            $this->query("UPDATE `base_messages` SET `read` = UTC_TIMESTAMP WHERE `id` = ?;", array($id));
        }
        return $res;
    }
    public function getAtchHeaders($name, $password, $message_id){
        $res = $this->login($name, $password);
        if(!NMError::is_error($res)){
            $sql = "SELECT `base_attachments`.`id`, `base_attachments`.`type` FROM `base_attachments` WHERE `base_attachments`.`message` = ?";
            //printf(str_replace("?","\"%s\"", $sql."<p></p>"), $message_id);
            $res = $this->query($sql, array($message_id));
        }
        return $res;
    }
    public function getAtchData($name, $password, $id){
        $res = $this->login($name, $password);
        if(!NMError::is_error($res)){
            $sql = "SELECT `base_attachments`.`data`, `base_attachments`.`type` FROM `base_attachments` WHERE `base_attachments`.`id` = ?";
            $stmt = $this->db->prepare($sql);
            $stmt->execute(array($id));
            $stmt->bindColumn(1, $data, PDO::PARAM_LOB);
            $stmt->bindColumn(2, $type);

            $stmt->fetch(PDO::FETCH_BOUND);
            return array("error" => 0, "data" => $data, "type" => $type);
            //printf(str_replace("?","\"%s\"", $sql."<p></p>"), $id);
            /*$res = $this->query($sql, array($id));
            if(!NMError::is_error($res)){
                if(count($res) == 0){
                    return NMError::data_success(0);
                }
                else{
                    return NMError::data_success($res[0]);
                }
            }*/
        }
        return $res;
    } 
}
?>