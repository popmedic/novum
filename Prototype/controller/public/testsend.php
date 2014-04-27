<html>
    <head>
        <meta name="viewport" content="width=device-width, user-scalable=no">
        <script src="http://code.jquery.com/jquery-1.11.0.min.js"></script>
        <script src="http://code.jquery.com/jquery-migrate-1.2.1.min.js"></script>
        <style>
            body{
                font-family:'Gill Sans', Arial, Helvetica;
            }
        </style>
    </head>
    <body>
        <div>Name:<input id="name" type="text" /></div>
        <div>Phone:<input id="phone_number" type="text" /></div>
        <div>Agency:<input id="agency" type="text" /></div>
        <div>Unit:<input id="unit" type="text" /></div>
        <div>Message:<input id="message" type="text" /></div>
        <div>Attachment:<input type="file" id="file1" /></div>
        <div>Attachment:<input type="file" id="file2" /></div>
        <div><button id="snd">Send</button></div>
    </body>
    <script>
        $(document).ready(function(){
            $('#snd').click(function(){
                var formData = new FormData();
                var fileInput = document.getElementById('file1');
                if($(fileInput).val() != "")
                {
                    var file = fileInput.files[0];
                    formData.append('file1', file);
                }
                fileInput = document.getElementById('file2');
                if($(fileInput).val() != "")
                {
                    var file = fileInput.files[0];
                    formData.append('file2', file);
                }
                formData.append('vars', JSON.stringify(
                    {
                        "name": $("#name").val(),
                        "phone_number": $("#phone_number").val(),
                        "agency": $("#agency").val(),
                        "unit": $("#unit").val(),
                        "mac_addr": "0",
                        "ui": "2",
                        "to": "1",
                        "message": $("#message").val()
                    }));
                $.ajax({
                    url: 'fieldusers/sendMessage.php',  //Server script to process data
                    type: 'POST',
                    //Ajax events
                    //beforeSend: beforeSendHandler,
                    success: function(d) { alert(d); },
                    //error: errorHandler,
                    // Form data
                    data: formData,
                    //Options to tell jQuery not to process data or worry about content-type.
                    cache: false,
                    contentType: false,
                    processData: false
                });   
            });
        });
    </script>
</html>