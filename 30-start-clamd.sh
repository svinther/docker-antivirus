#!/bin/bash

#Create the dir for clamd socket file
mkdir /var/run/clamav
chown clamav:clamav /var/run/clamav

#Wait for freshclam to have the databases initialized
FIRSTRUN=true
while [[ ! -f /var/lib/clamav/initialized.ok ]]; do
  if [[ "$FIRSTRUN" == true ]]; then
    echo Waiting to start clamd until freshclam initializes the databases;
    FIRSTRUN=false
  fi

  sleep 1;
done

#Run daemon in foreground mode
echo Starting clamd
exec clamd -F