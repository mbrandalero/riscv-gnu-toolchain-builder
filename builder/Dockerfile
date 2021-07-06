# builder
FROM centos:8

#   texinfo
RUN sed -i 's/enabled=0/enabled=1/' 9/etc/yum.repos.d/CentOS-Linux-PowerTools.repo
RUN yum install autoconf bison automake dtc expat-devel file flex gawk gcc gcc-c++ gmp-devel gtk2-devel libmpc-devel make mpfr-devel patchutils python3 zlib-devel -y

ENV RISCV="/riscv"
ENV PATH="${PATH}:${RISCV}"
WORKDIR /riscv-src/

# ENTRYPOINT ["/bin/bash"]
