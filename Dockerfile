FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TERM=xterm
RUN echo "export > /etc/envvars" >> /root/.bashrc && \
    echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" | tee -a /root/.bashrc /etc/bash.bashrc && \
    echo "alias tcurrent='tail /var/log/*/current -f'" | tee -a /root/.bashrc /etc/bash.bashrc

RUN apt-get update
RUN apt-get install -y locales && locale-gen en_US en_US.UTF-8

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD export > /etc/envvars && /usr/sbin/runsvdir-start

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute python ssh rsync

RUN apt-get --no-install-recommends -y install \
    build-essential pkg-config erlang \
    libicu-dev libmozjs185-dev libcurl4-openssl-dev

RUN wget -O - http://www-us.apache.org/dist/couchdb/source/2.0.0/apache-couchdb-2.0.0.tar.gz | tar zx && \
    cd apache-couchdb* && \
    ./configure --disable-docs && \
    make release && \
    mv rel/couchdb / && \
    rm -rf apache-couchdb
RUN mkdir -p /couchdb/data

COPY local.ini /couchdb/etc/local.d/

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO

