<?
if(!isset($vars->name)){
    print(json_encode(NMError::error("name var must be set")));
    exit();
}
if(!isset($vars->password)){
    print(json_encode(NMError::error("password var must be set")));
    exit();
}
?>