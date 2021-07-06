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


BUILDER := mbrandalero/riscv-tools-builder:with_automake1.14
TOOL := mbrandalero/riscv-tools

BASEDIR=$(CURDIR)
DOCKER = podman

RISCV-LOCAL := $(BASEDIR)/riscv
RISCV-CONTR := /riscv

RISCV-TOOLCHAIN-SRC-LOCAL := $(BASEDIR)/riscv-gnu-toolchain
RISCV-TOOLCHAIN-SRC-CONTR := /riscv-src/riscv-gnu-toolchain

RISCV-TOOLS-SRC-LOCAL := $(BASEDIR)/riscv-tools
RISCV-TOOLS-SRC-CONTR := /riscv-src/riscv-tools

#RISCV-BUILD-DIR = $(RISCV-SRC)/build

DOCKER-BUILDER-RUN := $(DOCKER) run --rm -i -t \
	-v${RISCV-LOCAL}:${RISCV-CONTR} \
	-v${RISCV-TOOLCHAIN-SRC-LOCAL}:${RISCV-TOOLCHAIN-SRC-CONTR} \
	-v${RISCV-TOOLS-SRC-LOCAL}:${RISCV-TOOLS-SRC-CONTR} \
	\
	${BUILDER}

.PHONY: toolflow-init
toolflow-init:
	mkdir riscv

.PHONY: builder
builder:
	$(DOCKER) build ./builder -t ${BUILDER}
	#$(DOCKER) push ${BUILDER}

builder-launch:
	$(DOCKER-BUILDER-RUN)

.PHONY: build-make-multilib
build-riscv-gnu-toolchain:
	mkdir -p riscv-gnu-toolchain/build
	${DOCKER-BUILDER-RUN} /bin/bash -c "cd ${RISCV-TOOLCHAIN-SRC-CONTR}/build && ../configure --prefix=${RISCV-CONTR} --enable-multilib"
	${DOCKER-BUILDER-RUN} /bin/bash -c "cd ${RISCV-TOOLCHAIN-SRC-CONTR}/build && make -j4"
	${DOCKER-BUILDER-RUN} /bin/bash -c "cd ${RISCV-TOOLCHAIN-SRC-CONTR}/build && make -j4 linux"

build-riscv-tools:
	${DOCKER-BUILDER-RUN} /bin/bash -c "cd ${RISCV-TOOLS-SRC-CONTR} && ./build.sh"

.PHONY: tool-chain
tool-chain:
	$(DOCKER) build ./bin -t ${TOOL}
	$(DOCKER) push ${TOOL}


.PHONY: build-hello
build-hello:
	$(DOCKER) run --rm -v $(BASEDIR)/app:/app -w /app ${TOOL} /riscv/bin/riscv64-unknown-elf-gcc -o hello hello.c

.PHONY: build
build: toolflow-init builder build-make-multilib tool-chain build-hello
