CRYSTAL_BIN ?= $(shell which crystal)
SHARDS_BIN ?= $(shell which shards)
PREFIX ?= /usr/local
SHARD_BIN ?= ../../bin

build: bin/astcli
bin/astcli:
	# $(SHARDS_BIN) build $(CRFLAGS)
	$(SHARDS_BIN) build --static --no-debug --progress --warnings=all
clean:
	rm -f ./bin/astcli ./bin/astcli.dwarf
install: build
	mkdir -p $(PREFIX)/bin
	cp ./bin/astcli $(PREFIX)/bin
bin: build
	mkdir -p $(SHARD_BIN)
	cp ./bin/astcli $(SHARD_BIN)
run_file:
	cp -r ./bin/astcli.cr $(SHARD_BIN)
test: build
	$(CRYSTAL_BIN) spec
