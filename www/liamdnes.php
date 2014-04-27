<?php
session_start();
$key = $_SESSION['key'];
$yek = $_REQUEST['yek'];
if($key == $yek){
	mail("mike@novumconcepts.com", "Customer Information Request", 
	"Name:".$_REQUEST['name'].
	"\r\nCompany/Organization:".$_REQUEST['company'].
	"\r\nEmail:".$_REQUEST['email']);
	print("Request Sent");
}
else
{
?>
dream about it.
<?php
}
?>