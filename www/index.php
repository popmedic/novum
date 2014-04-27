<?php
$key = uniqid("NOVUM");
session_start();
$_SESSION['key'] = $key;
session_write_close(); 
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0;" />
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
<title>Novum Concepts</title>
<style>
#logo{
	max-width:640px;
	width:100%;
	padding:10px;
	padding-bottom:40px;
}
body{
	font-family:Arial, Helvetica, sans-serif;
	line-height:1.5;
}
div{
	padding-top:10px;
	padding-bottom:10px;
	max-width:640px;
	text-align:left;
}
input[type=text]{
	border-radius:3px;
	border:#CCC 1px solid;
	padding-top:2px;
	padding-bottom:2px;
	padding-left:4px;
	padding-right:4px;
}
input[type=email]{
	border-radius:3px;
	border:#CCC 1px solid;
	padding-top:2px;
	padding-bottom:2px;
	padding-left:4px;
	padding-right:4px;
}
</style>
</head>

<body>
<center>
<img id="logo" src="images/novum_logo.png" />
<div>
Formed on the streets of Denver, Novum Concepts had a goal to create EMS tools used to make the job easier and pre-hospital care better. By looking at what is lacking in EMS and Emergency Medicine, simple solutions were created by the end user to allow better care. By having first hand experience, we are able to create a product that is actually user friendly. We are working hard to deliver outstanding products and will be launching our site in the near future.
</div>
<div>
Our current project is a series of apps used to transmit data from the field to a base client in a secure manner. This can be used for 12-lead transmission, injury images, and registration info. By installing a free app any paramedic, EMT, or other first responder, has the ability to alert the hospital of a incoming patient, and what to expect. EKG's will be read before the patient leaves their home, and patients will be registered before their arrival to ensure accurate billing and healthcare records.
</div>
<div>
If you would like more info regarding the Field Report, please enter your contact info and you will receive a brief summary of the program.
</div>
<div style="text-align:center">
<input id="contact_name" type="text" placeholder="Name" size="22" /><br />
<input id="contact_company" type="text" placeholder="Company/Organization" size="22" /><br />
<input id="contact_email" type="email" placeholder="Email Address" size="22" /><br />
<button id="send_contact">Send</button>
</div>
<div id="results">
</div>
<script language="javascript">
function validateEmail(email) { 
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
} 

function validateName(name){
	if(name == "") return false;
	return true;	
}

$(document).ready(function(e) {
    $("#send_contact").click(function(e) {
		$("#send_contact").attr("disabled", "disabled");
		name = $("#contact_name" ).val();
		company = $("#contact_company").val();
		email = $("#contact_email").val();
		
		if(!validateEmail(email)){
			alert("Email Address must be a valid email address.");
			$("#send_contact").removeAttr("disabled");
		}
		else if (!validateName(name)){
			alert("Name must be filled out.");
			$("#send_contact").removeAttr("disabled");
		}
		else{
			url = "./liamdnes.php?"+
								"name="+ encodeURIComponent(name)+
								"&company="+encodeURIComponent(company)+
								"&email="+encodeURIComponent(email)+
								"&yek=<?php print($key); ?>";
			$("#results").load(url, function(e){ 
				$("#contact_email").val("");
				$("#contact_company").val("");
				$("#contact_name").val("");
				$("#send_contact").removeAttr("disabled");
			});
		}
    });
});
</script>
</center></body>
</html>
