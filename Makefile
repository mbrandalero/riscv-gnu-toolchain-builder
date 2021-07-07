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


BUILDER := mbrandalero/riscv-tools-builder
TOOL := mbrandalero/riscv-toolchain

BASEDIR=$(CURDIR)
DOCKER = podman

RISCV-LOCAL := $(BASEDIR)/docker/riscv-toolchain/riscv
RISCV-CONTR := /riscv

RISCV-TOOLCHAIN-SRC-LOCAL := $(BASEDIR)/src/riscv-gnu-toolchain
RISCV-TOOLCHAIN-SRC-CONTR := /riscv-src/riscv-gnu-toolchain

RISCV-SPIKE-LOCAL := $(BASEDIR)/src/riscv-isa-sim
RISCV-SPIKE-CONTR := /riscv-src/riscv-isa-sim

RISCV-PK-LOCAL := $(BASEDIR)/src/riscv-pk
RISCV-PK-CONTR := /riscv-src/riscv-pk

#RISCV-BUILD-DIR = $(RISCV-SRC)/build

DOCKER-BUILDER-RUN := $(DOCKER) run --rm -i -t \
	-v${RISCV-LOCAL}:${RISCV-CONTR} \
	-v${RISCV-TOOLCHAIN-SRC-LOCAL}:${RISCV-TOOLCHAIN-SRC-CONTR} \
	-v${RISCV-SPIKE-LOCAL}:${RISCV-SPIKE-CONTR} \
	-v${RISCV-PK-LOCAL}:${RISCV-PK-CONTR} \
	\
	${BUILDER}

.PHONY: builder
builder:
	$(DOCKER) build ./docker/builder -t ${BUILDER}
	#$(DOCKER) push ${BUILDER}

.PHONY: run-builder
run-builder:
	${DOCKER-BUILDER-RUN}

.PHONY: build-make-multilib
riscv-gnu-toolchain:
	mkdir -p src/riscv-gnu-toolchain/build
	${DOCKER-BUILDER-RUN} /bin/bash -c "cd ${RISCV-TOOLCHAIN-SRC-CONTR}/build && ../configure --prefix=${RISCV-CONTR} --enable-multilib"
	${DOCKER-BUILDER-RUN} /bin/bash -c "cd ${RISCV-TOOLCHAIN-SRC-CONTR}/build && make -j4"
	
riscv-isa-sim:
	mkdir -p src/riscv-isa-sim/build
	${DOCKER-BUILDER-RUN} /bin/bash -c "cd ${RISCV-SPIKE-CONTR}/build && ../configure --prefix=${RISCV-CONTR}"
	${DOCKER-BUILDER-RUN} /bin/bash -c "cd ${RISCV-SPIKE-CONTR}/build && make -j4"
	${DOCKER-BUILDER-RUN} /bin/bash -c "cd ${RISCV-SPIKE-CONTR}/build && make install"

riscv-pk:
	mkdir -p src/riscv-pk/build
	${DOCKER-BUILDER-RUN} /bin/bash -c "cd ${RISCV-PK-CONTR}/build && ../configure --prefix=${RISCV-CONTR} --host=riscv64-unknown-elf --with-arch=rv32imc"
	${DOCKER-BUILDER-RUN} /bin/bash -c "cd ${RISCV-PK-CONTR}/build && make -j4"
	${DOCKER-BUILDER-RUN} /bin/bash -c "cd ${RISCV-PK-CONTR}/build && make install"

.PHONY: tool-chain
riscv-docker:
	$(DOCKER) build ./docker/riscv-toolchain -t ${TOOL}
	$(DOCKER) push ${TOOL}

.PHONY: test
test:
	echo "-- Trying to compile hello world ..."
	$(DOCKER) run --rm -v $(BASEDIR)/test:/test -w /test $(TOOL) riscv64-unknown-elf-gcc -march=rv32imc -mabi=ilp32 -o hello hello.c
	echo "Done!"
	echo "-- Trying to run hello world in ISA sim ..."
	$(DOCKER) run --rm -v $(BASEDIR)/test:/test -w /test $(TOOL) spike --isa=rv32imc /riscv/riscv32-unknown-elf/bin/pk hello 
	echo "Done!"

.PHONY: build-hello
build-hello:
	$(DOCKER) run --rm -v $(BASEDIR)/app:/app -w /app ${TOOL} /riscv/bin/riscv64-unknown-elf-gcc -o hello hello.c

all: builder riscv-gnu-toolchain riscv-isa-sim riscv-pk riscv-docker
