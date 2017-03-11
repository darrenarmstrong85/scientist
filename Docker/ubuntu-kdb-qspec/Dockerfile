FROM ubuntu-kdb-qutil:latest

RUN \
	curl --silent https://codeload.github.com/nugend/qspec/zip/master > qspec.zip && \
	unzip qspec.zip && \
	mv qspec-master $QPATH/lib/qspec && \
	ln -s $QPATH/lib/qspec/lib $QPATH/qspec && \
	rm qspec.zip

COPY qspec.sh /root/.bashrc.d

WORKDIR /
