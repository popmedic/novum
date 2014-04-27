#!/usr/local/bin/ruby

require('json')
require('rest_client')

def sendMessage(files, vars)
    json_vars = vars.to_json.gsub(/\n/,"")
#    cmd = "curl -F vars='"+json_vars+"' "
#    files.each_index do |idx|
#        cmd += "-F file"+idx.to_s+"=@'"+files[idx]+"' "    
#    end
#    cmd += "http://kevinscardina.com/novum/mc/api/public/fieldusers/sendMessage.php"
    res = RestClient.post("http://kevinscardina.com/novum/mc/api/public/fieldusers/sendMessage.php",
                          :vars => json_vars)
    return res.to_str
end

File.open("/home/kscardina/novum/mmsg/smsd-out.log", "a+") do |file|
    
    ENV.each_key do |key|
        if(/^SMS/ =~ key || /^DECODE/ =~ key)
            file.puts key + " = " + ENV[key]
        end
    end
    
    decode_n = ENV['DECODED_PARTS']
    phone_number = "[uknown]"
    msg = "[none]"
    if(decode_n != nil)
        if(decode_n.to_i == 0)
            phone_number =  ENV['SMS_1_NUMBER']
            msg = ENV['SMS_1_TEXT']
        else
            phone_number = ENV['DECODED_1_MMS_SENDER'].gsub(/\/.*$/,'')
            msg = ENV['DECODED_1_MMS_ADDRESS']+'_-\|/-_'+ENV['DECODED_1_MMS_TITLE']
        end
    end
    file.puts(phone_number+" "+msg)
    vars = {"name" => "Novum-MMSG", "phone_number" => phone_number, "agency" => "Novum-MMSG-Agency", "unit" =>"1", "mac_addr" => "0", "ui" => "2", "to" => "1", "message" => msg}
    file.puts 'Send Message:'
    vars.each_key do |key|
        file.puts "\t" + key +': ' + vars[key]
    end
    res = sendMessage([], vars)
    file.puts res
    file.puts "*"*50
end