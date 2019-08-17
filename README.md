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

Just compile it and start with command-line: `./astcli --help`.

### Docker

If you want just to use `astcli` within docker-container, simply use multi-stage
build. Example:

```dockerfile
FROM andrius/crystal-lang as astcli

WORKDIR /src
RUN git clone https://github.com/ctiapps/astcli.git . \
 && git checkout tags/v0.1.0
RUN shards build --production --release --no-debug --progress --warnings=all
# create list of deps to copy or astcli won't work with Alpine linux
RUN ldd ./bin/astcli | tr -s '[:blank:]' '\n' | grep '^/' | \
    xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%;'
RUN find ./deps/

#########################################################

FROM andrius/alpine-ruby:latest

# Copyng dependences. Could be skipped with Debian or Ubuntu
COPY --from=astcli /src/deps /
# that will fix DNS resolve issue in docker
COPY --from=astcli /lib/x86_64-linux-gnu/libnss_dns.so.* /lib/x86_64-linux-gnu/
COPY --from=astcli /lib/x86_64-linux-gnu/libresolv.so.*  /lib/x86_64-linux-gnu/

# Copy astcli script
COPY --from=astcli /src/bin/astcli /usr/local/bin/astcli

# Everything else...
ENV WORKDIR /app
WORKDIR ${WORKDIR}

ENV TIMEZONE "Europe/Amsterdam"

ENV DOCKER_BUILD_DEPS build-base \
  git \
  libxml2-dev \
  libxslt-dev \
  ...
```

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
