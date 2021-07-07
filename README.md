# Summary

This repository was forked from [mingz2013/riscv-gnu-toolchain-builder](https://github.com/mingz2013/riscv-gnu-toolchain-builder) and extended.

The original repo included only the riscv-gnu-toolchain and scripts to build a docker image containing the tools. This repo includes all that + [riscv-isa-sim](https://github.com/riscv/riscv-isa-sim) + [riscv-pk](https://github.com/riscv/riscv-pk). The scripts are tuned to generate the multilib version of the toolchain and the rv32imc version of `pk` so that it can /(hopefully, after some debugging) work with the [cv32e40p](https://github.com/openhwgroup/cv32e40p/) processor core.

A prebuilt version of the image containing the riscv toolchain is available at the (Docker Hub)[https://hub.docker.com/r/mbrandalero/riscv-toolchain]. 

# Getting Started

Run `make all` and see the magic happen. 

Compilation takes a few hours (~4) in a modern (as of 2021) desktop machine.

# Detailed Description

## Build Flow

The make script will first compile a _builder_ image with all the tools needed to compile the toolchain.

The toolchain will be built in a local directory mounted inside the container via a volume.

A final image is built by copying the directory with all the tools, after being compiled with the builder.

## Repository Structure

- `docker` contains the Dockerfiles for the two images that will be built.
- `src` contains the source files for riscv-gnu-toolchain, riscv-isa-sim and riscv-pk.
- `test` contains a test application (hello world) that is compiled with the riscv toolchain and run in the ISA simulator. 