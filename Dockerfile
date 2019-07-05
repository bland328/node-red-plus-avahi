# bland328/node-red-plus-homekit Dockerfile
#
# Node-RED Dockerfile with integrated Avahi to support node-red-contrib-homekit-bridged
#
# Intended for unRAID, but may serve others well
# Based heavily upon https://github.com/mschm/node-red-contrib-homekit/issues/8#issuecomment-362029068
#
# Build reminders to myself, as I don't deal with this very often:
#   1) AUTOBUILD IS ON AT https://cloud.docker.com/swarm/bland328/repository/docker/bland328/node-red-plus-homekit/general
#      SO ANY PUSHED CHANGE HERE RESULTS IN A BUILD BASED ON THE LATEST OFFICIAL NODE-RED DOCKER CONTAINER.
#   2) I also have REPOSITORY LINKS turned on at Docker Hub, so any change to the Base Image (in this case, the
#      official Node-RED Docker Container) also results in an auto-build.
#
# The resulting build is at https://store.docker.com/community/images/bland328/node-red-plus-homekit

# Overview:
# Based on the offical Node-RED docker
# add gosu (per https://github.com/tianon/gosu/blob/master/INSTALL.md)
# add avahi-daemon
# configure avahi-daemon execution
# DISABLED, AS THIS NEEDS TO BE INSTALLED BY THE USER: add node-red-contrib-homekit-bridged
# add entrypoint.sh

# Declare a Docker image on which to build
FROM nodered/node-red-docker

# Become root
USER root

# Download and install gosu
ENV GOSU_VERSION 1.11
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
    key="B42F6819007F00F88E364FD4036A9C25BF357DD4"; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key"; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    \
    chmod +x /usr/local/bin/gosu; \
    # verify the binary works
    gosu nobody true; \
    \
    apt-get purge -y --auto-remove $fetchDeps

# Set gosu ownership and permissions
RUN chown root:node-red /usr/local/bin/gosu && chmod +s /usr/local/bin/gosu

# Get avahi-daemon et al
RUN apt-get update -y && apt-get install -y apt-utils build-essential python make g++ avahi-daemon avahi-discover libnss-mdns libavahi-compat-libdnssd-dev

# Configure avahi-daemon
RUN sed -i "s/#enable-dbus=yes/enable-dbus=yes/g" /etc/avahi/avahi-daemon.conf
RUN mkdir -p /var/run/dbus && mkdir -p /var/run/avahi-daemon
RUN chown messagebus:messagebus /var/run/dbus && chown avahi:avahi /var/run/avahi-daemon && dbus-uuidgen --ensure

# Become user node-red
USER node-red

# Install node-red-contrib-homekit-bridged
# CURRENTLY DISABLED, AS THIS NEEDS TO BE INSTALLED BY THE USER, AFTER THE PERSISTANT /data DIR EXISTS
# RUN cd /data && npm install node-red-contrib-homekit-bridged

# Incorporate entrypoint.sh file, set its permissions, and declare it the entrypoint for the container
COPY entrypoint.sh /usr/src/node-red
RUN gosu root chmod 755 /usr/src/node-red/entrypoint.sh
ENTRYPOINT /usr/src/node-red/entrypoint.sh
