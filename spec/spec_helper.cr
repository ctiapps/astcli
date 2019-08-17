require "spec"
require "logger"
require "./helpers/*"
require "../src/astcli/*"
LOGGER = Logger.new(STDOUT)

STDOUT.sync = true
Spec.override_default_formatter(Spec::VerboseFormatter.new)

{% if flag?(:verbose) %}
    LOG_LEVEL = Logger::DEBUG
{% elsif flag?(:warn) %}
    LOG_LEVEL = Logger::WARN
{% else %}
    LOG_LEVEL = Logger::ERROR
{% end %}

def logger
  LOGGER
end
logger.level = LOG_LEVEL

module TestHelpers
  def with_asterisk(username = "astcli", secret = "astcli", &block)
    unless Asterisk::Server.running?
      Asterisk::Server.start
      # let Asterisk start
      sleep 3.seconds
    end

    asterisk = AstCLI::AMI.new username: username, secret: secret
    yield asterisk
    asterisk.disconnect
  end
end

extend TestHelpers
