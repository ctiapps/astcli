AstCLI
======

Crystal version of Asterisk PBX [astcli](https://github.com/asterisk/asterisk/blob/master/contrib/scripts/astcli) utility.

## Why?

I am working on cloud project, that works in docker swarm; Asterisk PBX running
in host networking mode; AMI and ARI clients connected with asterisk through
`docker0` interface.

However, in order to get main application started, some initial operations and
validations should be made (with Asterisk), either before app get started, in
`docker-entrypoint` script... So it is why I've created this tool.

## Usage

Use it same way as original `astcli` utility:

```bash
./astcli -u ${ASTERISK_AMI_USERNAME} \
         -s ${ASTERISK_AMI_PASSWORD} \
         -h ${ASTERISK_HOST:-$(ip route | grep default | head -n 1 | cut -d' ' -f3)} \
         -p ${ASTERISK_AMI_PORT} \
         dialplan show globals
```

Additionally, it is possible to execute any AMI action, not only AMI action
'command', as with original `astcli`. To do so, just pass JSON string as
argument:

```bash
./astcli -u ${ASTERISK_AMI_USERNAME} \
         -s ${ASTERISK_AMI_PASSWORD} \
         -h ${ASTERISK_HOST:-$(ip route | grep default | head -n 1 | cut -d' ' -f3)} \
         -p ${ASTERISK_AMI_PORT} \
         "{\"Action\": \"SIPpeers\"}"
```

## Examples

Asterisk CLI command:

```bash
crystal src/astcli.cr -- -u astcli -s astcli "dialplan show globals" | grep "CONSOLE="
# => CONSOLE=Console/dsp
```

Asterisk AMI action:

```bash
crystal src/astcli.cr -- -u astcli -s astcli '{"Action": "GetConfig", "filename": "extensions.conf"}'
# =>
# {
#   "response": "Success",
#   "actionid": "GetConfig-5cac06e9-51cb-4c20-bdce-9bd641e72dc1",
#   "category-000000": "general",
#   "line-000000-000000": "static=yes",
#   "line-000000-000001": "writeprotect=no",
#   "line-000000-000002": "clearglobalvars=no",
#   "category-000001": "globals",
#   "line-000001-000000": "CONSOLE=Console/dsp",
#   ...

crystal src/astcli.cr -- -u astcli -s astcli '{"Action": "GetConfig", "filename": "extensions.conf"}' | \
jq -r '."line-000001-000000"'
# => CONSOLE=Console/dsp
```

## Installation

TODO: Write instructions here (installation/compilation, how-to use it with
docker)

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/andrius/astcli/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Andrius Kairiukstis](https://github.com/andrius) - creator and maintainer
