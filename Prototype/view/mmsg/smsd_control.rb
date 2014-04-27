#!/usr/local/bin/ruby

class SMSDControl
    def usage
        puts "./smsd_control [start/stop]"
    end
    def main
        if(ARGV.length != 1)
            self.usage 
        elsif(/start/i =~ ARGV[0].strip)
            `gammu-smsd --config gammu_config --pid gammu-smsd.pid --daemon`
        elsif(/stop/i =~ ARGV[0].strip)
            pid = `pidof gammu-smsd`
            `sudo kill -s KILL #{pid}`
        end
    end
end
smsdc = SMSDControl.new
smsdc.main