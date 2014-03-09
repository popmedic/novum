<?php
class NMError{
    public static function error($msg){
        return array("error" => $msg);   
    }
    public static function db_success($rows){
        return array("error" => 0, "rows" => $rows);
    }
    public static function id_success($id){
        return array("error" => 0, "id" => $id);
    }
    public static function is_error($res){
        if($res["error"] == 0){
            return false;
        }
        return true;
    }
    public static function get_error($res){
        return $res["error"];
    }
    public static function get_db_success($res){
        return $res['rows'];
    }
    public static function get_id($res){
        return $res['id'];
    }
}
?>