require 'open-uri'

# Set the request URL
url = 'http://elg2mmsget.msg.eng.t-mobile.com/mms/wapenc?location=17205140795_41oryj&rid=220'

# Set the request authentication headers
timestamp = Time.now.strftime('%Y%m%d %H:%M:%S')
headers = {}

# Send the GET request                              
resp = request(url)
puts resp.headers