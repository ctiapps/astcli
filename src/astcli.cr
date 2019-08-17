require "./astcli/*"

options = AstCLI::CommandLine.new

ami = AstCLI::AMI.new host: options.host,
                      port: options.port,
                      username: options.username,
                      secret: options.secret

result = ami.send_action options.action

puts result
