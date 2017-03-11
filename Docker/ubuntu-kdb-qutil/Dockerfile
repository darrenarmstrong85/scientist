FROM ubuntu-kdb:latest

ENV QPATH /qlibs

RUN \
	curl --silent https://codeload.github.com/nugend/qutil/zip/master > qutil.zip && \
	unzip qutil.zip && \
	mkdir -p $QPATH/lib && \
	mv qutil-master $QPATH/lib/qutil && \
	ln -s $QPATH/lib/qutil/lib $QPATH/qutil && \
	rm qutil.zip && \
	rm /q/q.q && \
	ln -s $QPATH/lib/qutil/q_q.sample /q/q.q && \
	ln -s $QPATH/qutil/bootstrap.q $QPATH/bootstrap.q

COPY qutil.sh /root/.bashrc.d

WORKDIR /
