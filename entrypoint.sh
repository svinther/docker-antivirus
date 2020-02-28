#!/bin/bash

if [[ "$1" != "antivirus" ]]; then
 exec $@
fi 

set -m

clamd -F -c /etc/clamd.conf &
freshclam -d &
httpd -D FOREGROUND &
pids=$(jobs -p)

kill_pids() {
 for pid in $pids; do
  if kill -0 $pid 2>/dev/null; then
   echo Killing pid $pid
   kill $pid 2>/dev/null && wait $pid
  fi
 done
}

#on SIGINT kill jobs
int_h() {
 trap "" CHLD
 kill_pids
}
trap int_h INT TERM

#On job exit, kill all jobs and return exit code of job that exited
exitcode=0
chld_h() {
 trap "" CHLD

 #Store exit code of gone process
 for pid in $pids; do
  if ! kill -0 $pid 2>/dev/null; then
   echo "pid $pid process gone" 1>&2
   wait $pid
   exitcode=$?
  fi
 done

 kill_pids
}

trap chld_h CHLD
wait

exit $exitcode
