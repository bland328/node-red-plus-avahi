#!/bin/bash

# Remove cruft
[[ -e /var/run/dbus.pid ]] && su-exec root rm -f /var/run/dbus.pid
[[ -e /var/run/avahi-daemon/pid ]] && su-exec root rm -f /var/run/avahi-daemon/pid
[[ -e /var/run/dbus/system_bus_socket ]] && su-exec root rm -f /var/run/dbus/system_bus_socket

# Restart services (no longer needed?)
#su-exec root service dbus restart
#su-exec root service avahi-daemon restart

# Start Node.js
npm start -- --userDir /data
