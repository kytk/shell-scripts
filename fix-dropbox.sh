#!/bin/sh
#dropbox stop && DBUS_SESSION_BUS_ADDRESS="" dropbox start 
sleep 7
kill $(ps -ef | grep dropbox-dist | grep -v grep | awk '{ print $2 }') \
&& dbus-launch dropbox start

