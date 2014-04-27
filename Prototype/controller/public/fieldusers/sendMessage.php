<?php
require_once("../validate_has_vars.php");
require_once("fieldusers.inc.php");

$fu = new FieldUsers();
$ip = $_SERVER['REMOTE_ADDR'];
$dbg_out = fopen("../sendMessage_dgb_out.txt", "a+");
dbgout("Sending message...");
$res = $fu->sendMessage($vars->name, 
                        $vars->phone_number, 
                        $vars->agency, 
                        $vars->unit, 
                        $ip, 
                        $vars->mac_addr, 
                        $vars->ui, 
                        $vars->to, 
                        $vars->message);
if(!NMError::is_error($res)){
    $mid = NMError::get_id($res);
    dbgout("Got new message ID: ".$mid);
    $fn = 'file1';
    $i = 1;
    while(isset($_FILES[$fn]["error"]) && $_FILES[$fn]["error"] !== null){
        dbgout("Attach file: ".$fn);
        if($_FILES[$fn]['error'] > 0){
            dbgout("UNABLE TO GET UPLOADED FILE. RETURN CODE: ".$_FILES[$fn]);
            print(json_encode(NMError::error("UNABLE TO GET UPLOADED FILE. Return Code: ".$_FILES[$fn]["error"])));
            exit();
        }
        else{
            if (/*(($_FILES[$fn]["type"] == "image/gif")   || 
                 ($_FILES[$fn]["type"] == "image/jpeg")  || 
                 ($_FILES[$fn]["type"] == "image/jpg")   || 
                 ($_FILES[$fn]["type"] == "image/pjpeg") || 
                 ($_FILES[$fn]["type"] == "image/x-png") || 
                 ($_FILES[$fn]["type"] == "image/png"))  && */
                 ($_FILES[$fn]["size"] < 16777216)){
                if(is_uploaded_file($_FILES[$fn]['tmp_name'])) {
                    $tmp_data = file_get_contents($_FILES[$fn]["tmp_name"]);
                    
                    $finfo = new finfo(FILEINFO_MIME_TYPE);
                    $type = $finfo->file($_FILES[$fn]['tmp_name']);
                    dbgout("Adding attachment.");
                    $r = $fu->addAttachment($mid, $tmp_data, $type);
                    if(NMError::is_error($r)){
                        print(json_encode($r));
                        exit();
                    }
                }
                else{
                    print(json_encode(NMError::error("File: \"".$_FILES[$fn]['tmp_name']."\" does not exist.")));
                    dbgout("FILE: ".$_FILES[$fn]['tmp_name']." DOES NOT EXIST");
                    exit();
                }
            }
            else{
                print(json_encode(NMError::error("File is too big.")));
                dbgout("File to big");
                exit();
            }
        }
        $i += 1;
        $fn = preg_replace('/[0-9]+$/', (string)$i, $fn);
    }
}
print(json_encode($res));
?>