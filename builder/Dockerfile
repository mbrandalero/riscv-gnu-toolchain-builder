# builder
FROM centos:8

#   texinfo
RUN sed -i 's/enabled=0/enabled=1/' 9/etc/yum.repos.d/CentOS-Linux-PowerTools.repo
RUN yum install autoconf bison automake dtc expat-devel file flex gawk gcc gcc-c++ gmp-devel gtk2-devel libmpc-devel make mpfr-devel patchutils  zlib-devel -y
RUN yum install   -y
RUN yum install  -y
RUN yum install python3 -y

RUN curl -O http://ftp.gnu.org/gnu/make/make-4.2.1.tar.gz && \
    tar -zxvf make-4.2.1.tar.gz && \
    cd make-4.2.1 && \
    ./configure && \
    make -j2 && \
    make install && \
    make -v && \
    ln -s /usr/local/bin/make /usr/local/bin/gmake && \
    ln -s /usr/local/bin/make /usr/local/bin/gnumake

ENV RISCV="/riscv"
ENV PATH="${PATH}:${RISCV}"
WORKDIR /riscv-src/

# ENTRYPOINT ["/bin/bash"]
