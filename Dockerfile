# Based on the offical Node-RED docker,
# add gosu (per https://github.com/tianon/gosu/blob/master/INSTALL.md)
# add avahi-daemon
# add node-red-contrib-homekit

FROM nodered/node-red-docker
USER root

# Install gosu 
ENV GOSU_VERSION 1.10
RUN set -ex; \
    \
    fetchDeps=' \
        ca-certificates \
        wget \
    '; \
    apt-get update; \
    apt-get install -y --no-install-recommends $fetchDeps; \
    rm -rf /var/lib/apt/lists/*; \
    \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
    \
# verify the signature
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    \
    chmod +x /usr/local/bin/gosu; \
# verify that the binary works
    gosu nobody true; \
    \
    apt-get purge -y --auto-remove $fetchDeps

RUN chown root:node-red /usr/local/bin/gosu && chmod +s /usr/local/bin/gosu
RUN apt-get update -y && apt-get install -y apt-utils build-essential python make g++ avahi-daemon avahi-discover libnss-mdns libavahi-compat-libdnssd-dev

USER node-red
COPY entrypoint.sh /usr/src/node-red
