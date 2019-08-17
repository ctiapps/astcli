# Give access to the Asterisk PBX through linux shell commands
module Asterisk
  module Server
    @@asterisk_full_path : String | Nil

    def self.asterisk
      @@asterisk_full_path ||= shell_command(%(which asterisk))
    end

    # start Asterisk PBX in background (forked)
    def self.start
      shell_command %(#{asterisk} -vvvdddF)
    end

    def self.stop
      shell_command %(#{asterisk} -rx "core stop now")
    end

    def self.kill
      shell_command %(ps x | grep "asterisk -vvv" | grep -v grep | awk '{print $1}' | xargs kill -9)
      sleep 0.5.seconds
    end

    def self.running? : Bool
      result = shell_command(%(asterisk -rx "core show uptime"))
      ! result.empty? && (result =~ /Unable to connect/i).nil?
    end

    def self.version : String
      shell_command %(#{asterisk} -V).split.last
    end

    def self.shell_command(command)
      io = IO::Memory.new
      Process.run(command, shell: true, output: io)
      io.close
      io.to_s.chomp.strip
    end
  end
end
