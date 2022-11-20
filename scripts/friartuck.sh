#!/bin/bash

bailout(){ 

logger -t $tag "$0 Finishing. Signaling $pid to do the same"
touch /tmp/hastop.$pid
while [ -f /tmp/hastop.$pid ];do
	sleep 5;done
	logger -t $tag "$0 Finished"
	exit 0
}

reread(){

logger -t $tag "$0 signalling $pid to reread config"
touch /tmp/haread.$pid

}

trap bailout 3
trap reread 4
tar="friartuck ($$)"
debug=9
DELAY=10
pid=0
cd `dirname $0`
logger -t $tag "Starting HA Monitor Monitoring"



while :;do
	sleep $DELAY
	[ "$debug" -gt "2" ] && logger -t $tag "Checking hamonitor.sh"
	NewPID=`pgrep -u root hamonitor.sh`
	if [ -z "$NewPID" ]; then
		# no process found. child is dead.
		logger -t $tag "No HA process found"
		logger -t $tag "Starting \"`pwd`/hamonitor.sh\""
		nohup `pwd`/hamonitor.sh > /dev/null 2>&1 &
		pid=0
	elif [ "$NewPID" != "$pid" ]; then
		logger -t $tag "HA process rediscovered as $NewPID (was $pid)"
		pid=$NewPID;else
		# ALL is well
		[ "$debug" -gt "3" ] && logger -t $tag "hamonitor.sh is running";fi
done



