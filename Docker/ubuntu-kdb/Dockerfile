FROM ubuntu-kdb-deps:latest

ENV QHOME /q
ENV PATH ${PATH}:${QHOME}/l32/

# Install kdb+
COPY q.zip /

RUN \
	unzip q.zip && \
	rm q.zip

COPY qq.sh /root/.bashrc.d

WORKDIR /
