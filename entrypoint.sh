#!/bin/bash

if [[ "$1" != "antivirus" ]]; then
 exec $@
fi 

set -m

clamd &
freshclam -d &
httpd -D FOREGROUND &

#on SIGINT kill jobs
pids=$(jobs -p)
int_h() {
 trap "" CHLD
 kill $pids 2>/dev/null
}
trap int_h INT

#On job exit, kill all jobs and return exit code of job that exited
exitcode=0
chld_h() {
 trap "" CHLD

 #Store exit code of gone process
 for pid in $pids; do
  if ! kill -0 $pid 2>/dev/null; then
   echo "pid $pid process gone"
   wait $pid
   exitcode=$?
  fi
 done

 kill $pids 2>/dev/null
}

trap chld_h CHLD
wait

exit $exitcode
