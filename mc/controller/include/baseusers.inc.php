<?php
require_once('db.inc.php');

class BaseUsers extends Db {
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
        return new DateTime("1975-10-21 04:20:00");
    }
    public function checkForMessages($name, $password, $start=null, $end=null){
        $res = $this->login($name, $password);
        if(!NMError::is_error($res)){
            $sql = "SELECT ".
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
                   " `customers`.`name` AS `tcustname`, ".
                   " `base_users`.`pubkey` AS `tpubkey`, ".
                   " `base_users`.`ui` AS `tuiid`, ".
                   " `uis`.`name` AS `tuiname`, ".
                   " `base_users`.`checked` AS `tchecked`, ".
                   " `messages`.`ts` AS `sentts`, ".
                   " `messages`.`message` AS `message`, ".
                   " `attachments`.`data` AS `attachment` ".
                   "FROM ".
                   " `field_users`, ".
                   " `base_users`, ".
                   " `customers`, ".
                   " `uis`, ".
                   " `messages`, ".
                   " `attachments` ".
                   " WHERE ".
                   " `field_users`.`id` = `messages`.`from` and ".
                   " `base_users`.`id` = `messages`.`to` and ".
                   " `customers`.`id` = `base_users`.`customer` and ".
                   " `uis`.`id` = `base_users`.`ui` and ".
                   " `attachments`.`message` = `messages`.`id` and ".
                   " `messages`.`ts` > ? and ".
                   " `messages`.`ts` <= ? and ".
                   " `base_users`.`id` = ?;";
            $buid = NMError::get_id($res);
            $dts = null;
            $dte = null;
            $nc = false;
            
            if($start == null){
                $dts = $this->getChecked($buid);
            }
            else{
                $dts = new DateTime($start);
            }
            if($dts == null) $dts = $this->getChecked($buid);
            
            if($end == null){
                $nc = true;
                $dte = new DateTime;
            }
            else{
                $dte = new DateTime($end);
            }
            if($dte == null) $dte = new DateTime;
            
            //$sql = file_get_contents('./sql/checkformessages.sql');
            $res = $this->query($sql, array($buid, $dts->format('Y-m-d H:i:s.u'), $dte->format('Y-m-d H:i:s.u')));
            if(nc) {
                $this->query("UPDATE base_users SET checked = ? WHERE id = ?", array($dte->format('Y-m-d H:i:s.u'), $buid));
            }
        }
        return $res;
    }
}
?>