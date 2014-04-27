<?php
class NMError{
    public static function error($msg){
        return array("error" => $msg);   
    }
    public static function db_success($rows){
        return array("error" => 0, "rows" => $rows);
    }
    public static function data_success($row){
        if($row == 0) return array("error" => 0, "data" => 0);
        return array("error" => 0, "data" => $row["data"], "type" => $row["type"]);
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
    public static function get_data($res){
        return $res['data'];
    }
    public static function get_type($res){
        return $res['type'];
    }
}
?>