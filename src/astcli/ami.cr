require "asterisk/ami"
require "json"

module AstCLI
  class AMI
    getter ami : Asterisk::AMI

    def initialize(@host = "localhost", @port = "5038", @username = "", @secret = "")
      @ami = Asterisk::AMI.new host: host,
                               port: port,
                               username: username,
                               secret: secret
      connect
    end

    def connect
      ami.login
    end

    def disconnect
      ami.logoff
    end

    def connected?
      ami.connected?
    end

    def send_action(action : Action) : String
      response = ami.send_action(action, expects_answer_before: 2.0)

      # format response
      data = {} of String => String | Array(Hash(String, Array(String) | String))
      data = data.merge(response.data)
      if response.events
        data["events"] = response.events.as(Array(Hash(String, Array(String) | String)))
      end

      if action["action"] =~ /Command/i
        # Asterisk CLI command return one or multiple strings as response
        [response["output"]? || response["unknown"]? || ["No data"]].flatten.join("\n")
      else
        # return JSON for Asterisk AMI action
        data.to_pretty_json.to_s
      end
    end
  end
end
