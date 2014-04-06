<?php
function dbgout($str){
    global $dbg_out;
    if(isset($dbg_out)){
        fprintf($dbg_out, "%s\n", $str);
        fflush($dbg_out);
    }
}
?>