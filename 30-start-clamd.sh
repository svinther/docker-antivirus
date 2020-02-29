#!/bin/bash

mkdir /var/run/clamav
chown clamav:clamav /var/run/clamav
exec clamd -F