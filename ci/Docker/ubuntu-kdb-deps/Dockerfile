FROM ubuntu:latest

RUN apt-get update && apt-get install -y curl rlwrap unzip libc6-i386

RUN mv /root/.bashrc /root/.bashrc_old

COPY .bashrc /root/.bashrc

RUN mkdir -p /root/.bashrc.d

WORKDIR /
