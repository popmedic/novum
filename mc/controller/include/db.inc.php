<?php
require_once('config.inc.php');
require_once('nmerror.inc.php');

class Db{
    protected $db;
    function __construct(){
        global $MYSQL_HOST, $MYSQL_USER, $MYSQL_PASS;
        try {
            $this->db = new PDO($MYSQL_HOST, $MYSQL_USER, $MYSQL_PASS);
        } 
        catch (PDOException $e) {
            print json_encode(NMError::error($e->getMessage()));
            die();
        }   
    }
    function __destroy(){
        $this->db->close();
    }
    function query($sql, $values=null){
        try {
            $stmt = $this->db->prepare($sql);
            if($values == null){
                $stmt->execute();
            }
            else{
                $stmt->execute($values);
            }
            $rows = array();
            while($row = $stmt->fetch(PDO::FETCH_ASSOC)){
                array_push($rows, $row);
            }
            return NMError::db_success($rows);
        } 
        catch (PDOException $e) {
            return NMError::error($e->getMessage());
        } 
    }
}
?>