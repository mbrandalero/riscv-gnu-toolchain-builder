# tool-chains
FROM centos:8

RUN sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/CentOS-Linux-PowerTools.repo
RUN yum install dtc libmpc-devel -y

ENV RISCV="/riscv"
ENV PATH="${PATH}:${RISCV}/bin"
COPY ./riscv /riscv
# RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

# RUN echo 'export PATH=$PATH:/riscv/bin' > /root/.bashrc
