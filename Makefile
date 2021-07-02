.PHONY: help
help:
	@echo '                                                                          '
	@echo 'Makefile for riscv doc                                                    '
	@echo '                                                                          '
	@echo 'Usage:                                                                    '
	@echo '   make help                           show help                          '
	@echo '                                                                          '
	@echo '   make git-clone                     clone source                        '
	@echo '   make builder                       builder image                       '
	@echo '   make build-tool-chain                    tool chain image                    '
	@echo '   make build                         build all                           '
	@echo '                                                                          '
	@echo '                                                                          '


BUILDER := mbrandalero/riscv-gnu-toolchain-builder
TOOL := mbrandalero/riscv-gnu-toolchain

BASEDIR=$(CURDIR)
DOCKER = podman

RISCV := $(BASEDIR)/bin/riscv
RISCV-SRC := $(BASEDIR)/src/riscv-gnu-toolchain
RISCV-ISASIM-SRC := $(BASEDIR)/src/riscv-isa-sim

RISCV-IN := /opt/riscv
RISCV-SRC-IN := /riscv-gnu-toolchain
RISCV-ISASIM-SRC-IN := /riscv-isa-sim

RISCV-BUILD-DIR = $(RISCV-SRC)/build

DOCKER-BUILDER-RUN := $(DOCKER) run --rm -i -t -v${RISCV}:${RISCV-IN} -v${RISCV-SRC}:${RISCV-SRC-IN} -v${RISCV-ISASIM-SRC}:${RISCV-ISASIM-SRC-IN} ${BUILDER}

.PHONY: git-clone
git-clone:
	git clone --recursive https://github.com/riscv/riscv-gnu-toolchain ${RISCV-SRC}
	mkdir -p ${RISCV-SRC}/build
	git clone --recursive https://github.com/riscv/riscv-isa-sim ${RISCV-ISASIM-SRC}
	mkdir -p ${RISCV-ISASIM-SRC}/build
	#git clone https://github.com/riscv/riscv-gnu-toolchain ${RISCV-SRC}
	#cd ${RISCV-SRC} && git submodule update --init --recursive

.PHONY: builder
builder:
	$(DOCKER) build ./builder -t ${BUILDER}
	#$(DOCKER) push ${BUILDER}


.PHONY: build-make-multilib
build-make-multilib:
	${DOCKER-BUILDER-RUN} /bin/bash -c "cd /riscv-gnu-toolchain/build && ${RISCV-SRC-IN}/configure --prefix=${RISCV-IN} --enable-multilib"
	${DOCKER-BUILDER-RUN} /bin/bash -c "cd /riscv-isa-sim/build && ${RISCV-ISASIM-SRC-IN}/configure --prefix=${RISCV-IN} --enable-multilib"
	${DOCKER-BUILDER-RUN} /bin/bash -c "cd /riscv-gnu-toolchain/build && make"
	${DOCKER-BUILDER-RUN} /bin/bash -c "cd /riscv-gnu-toolchain/build && make linux"
	${DOCKER-BUILDER-RUN} /bin/bash -c "cd /riscv-isa-sim/build && make"
	${DOCKER-BUILDER-RUN} /bin/bash -c "cd /riscv-isa-sim/build && make install"


.PHONY: tool-chain
tool-chain:
	$(DOCKER) build ./bin -t ${TOOL}
	$(DOCKER) push ${TOOL}


.PHONY: build-hello
build-hello:
	$(DOCKER) run --rm -v $(BASEDIR)/app:/app -w /app ${TOOL} /riscv/bin/riscv64-unknown-elf-gcc -o hello hello.c

.PHONY: build
build: git-clone builder build-make-multilib tool-chain build-hello
