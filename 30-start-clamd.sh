#!/bin/bash

#Wait for freshclam to have the databases initialized
RUNS=0
while [[ ! -f /var/lib/clamav/initialized.ok ]]; do
  if [[ "$RUNS" -eq 0 ]]; then
    echo Waiting to start clamd until freshclam initializes the databases;
  elif [[ "$RUNS" -ge 90 ]]; then
    echo "Timeout waiting for freshclam"
    exit 1
  fi

  sleep 1;
  RUNS=$(($RUNS+1))
done

#Run daemon in foreground mode
echo Starting clamd
exec clamd -F