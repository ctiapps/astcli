require "option_parser"
require "json"

module AstCLI
  class CLI
    getter host     = "localhost"
    getter port     = "5038"
    getter username = ""
    getter secret   = ""
    getter action   = Action.new

    def initialize(command_line : Array(String) = ARGV)
      parse(command_line)
    end

    def parse(command_line)
      if command_line.empty?
        help
      end

      parser.parse(command_line)
      if username.empty? || secret.empty?
        help
      end

      # remaining data is a command or AMI action for Asterisk
      build_ami_action(command_line)
    end

    def build_ami_action(command_line)
      if command_line.empty?
        STDERR.puts "ERROR: missing argument: Asterisk CLI command or AMI action"
        help
      end

      data = if command_line.size > 1
        command_line.join(" ").strip
      else
        # it will try to parse command line as JSON (AMI action) with failback
        # (data wiill be processed as asterisk cli command in case of error
        begin
          # with only one argument we try to process action as a JSON
          json = JSON.parse(command_line.first)
          hash = json.as_h?
          if hash
            hash.try &.map { |k,v| {k.to_s.downcase => v.to_s} }.reduce { |acc, e| acc.merge(e) }
          else
            command_line.first
          end
        rescue
          command_line.first
        end
      end

      @action = if data.is_a?(String)
        {"action" => "Command", "command" => data}
      else
        data.as(Action)
      end
    end

    def help
      parser.parse(["--help"])
      exit(1)
    end

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: astcli [options] [asterisk CLI command or JSON (AMI action)]"

        opts.on("-?", "--help", "Show this help") do
          STDERR.puts opts
        end

        opts.on("-u USERNAME", "--username=USERNAME", "Specifies the username") do |option|
          @username = option
        end

        opts.on("-s SECRET", "--password=SECRET", "Specifies the secret") do |option|
          @secret = option
        end

        opts.on("-h HOST", "--host=HOST", "Specifies the hostname or IP address") do |option|
          @host = option
        end

        opts.on("-p PORT", "--port=PORT", "Specifies the port") do |option|
          @port = option
        end

        opts.invalid_option do |flag|
          STDERR.puts "ERROR: #{flag} is not a valid option."
          STDERR.puts opts
          exit(1)
        end
      end
    end
  end
end
