#!/bin/bash
# Clean up
[[ -e /var/run/dbus.pid ]] && gosu root rm -f /var/run/dbus.pid
[[ -e /var/run/avahi-daemon/pid ]] && gosu root rm -f /var/run/avahi-daemon/pid
[[ -e /var/run/dbus/system_bus_socket ]] && gosu root rm -f /var/run/dbus/system_bus_socket
# Start services
gosu root service dbus restart
gosu root service avahi-daemon restart
# Start Node.js
npm start -- --userDir /data
