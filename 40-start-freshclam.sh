#!/bin/bash

#it is not working for all volume kinds, by doing this from Dockerfile only
chown clamav:clamav /var/lib/clamav

#Make sure the database is initialized
echo "Running freshclam"
freshclam && touch /var/lib/clamav/initialized.ok

#Run daemon in foreground mode
echo "Starting freshclam daemon"
exec freshclam -dF
