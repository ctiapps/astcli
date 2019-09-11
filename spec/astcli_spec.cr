require "./spec_helper"

describe AstCLI do
  it "should correctly process command line options (credentials)" do
    astcli = AstCLI::CLI.new command_line: %w(-u foo -s bar sip show peers)
    astcli.username.should eq("foo")
    astcli.secret.should eq("bar")
  end

  it "should correctly process Asterisk CLI command from command line" do
    astcli = AstCLI::CLI.new command_line: %w(-u foo -s bar sip show peers)
    astcli.action.should eq({"action" => "Command", "command" => "sip show peers"})

    astcli = AstCLI::CLI.new command_line: ["-u", "foo", "-s", "bar", "sip show peers"]
    astcli.action.should eq({"action" => "Command", "command" => "sip show peers"})
  end

  it "should correctly process Asterisk AMI action as JSON" do
    astcli = AstCLI::CLI.new command_line: ["-u", "foo", "-s", "bar", "{\"action\": \"SIPpeers\"}"]
    astcli.action.should eq({"action" => "SIPpeers"})
  end

  it "should connect with Asterisk AMI" do
    unless Asterisk::Server.running?
      Asterisk::Server.start
      # let Asterisk start
      sleep 3.seconds
    end
    asterisk = AstCLI::AMI.new(username: "astcli", secret: "astcli")
    asterisk.connected?.should be_truthy
    asterisk.disconnect
  end

  it "send_action should return multi-line string for asterisk CLI command" do
    with_asterisk do |asterisk|
      result = asterisk.send_action({"action" => "Command", "command" => "dialplan show globals"})
      result.should be_a(String)
      # CONSOLE=Console/dsp is an default asterisk dialplan as variable
      result.should match /CONSOLE=/m
    end
  end

  it "send_action shoud return JSON for AMI action" do
    with_asterisk do |asterisk|
      result = asterisk.send_action({"action" => "IAXpeers"})
      result.should be_a(String)
      pp result
      JSON.parse(result).as_h["response"].as_s.should match /Success/i
      result = asterisk.send_action({"action" => "Ping"})
      JSON.parse(result).as_h["ping"].as_s.should match /Pong/i
    end
  end
end
