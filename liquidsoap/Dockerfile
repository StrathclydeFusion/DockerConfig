FROM debian:jessie

MAINTAINER Robert Wilson

RUN apt-get -q update && \
    apt-get -q -y install liquidsoap supervisor && \
    apt-get clean

RUN touch /run.sh && chmod 777 /run.sh
COPY ./supervisor.sh /
COPY ./supervisord.conf /etc/

#ENTRYPOINT ["liquidsoap"]
CMD ['-h']
# USER nobody
