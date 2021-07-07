# builder
FROM centos:8

#   texinfo
RUN sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/CentOS-Linux-PowerTools.repo
RUN yum install autoconf bison automake diffutils dtc expat-devel file flex gawk gcc gcc-c++ git gmp-devel gtk2-devel libmpc-devel libtool make mpfr-devel patchutils python3 texinfo zlib-devel -y

ENV RISCV="/riscv"
ENV PATH="${PATH}:${RISCV}/bin"
WORKDIR /riscv-src/

# ENTRYPOINT ["/bin/bash"]
