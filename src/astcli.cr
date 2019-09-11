require "./astcli/*"

module AstCLI
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
end
