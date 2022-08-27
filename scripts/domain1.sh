#!/bin/bash

# Lock is a global variable. For this usage, lock.myapp.$$ is not suitable. 
# var/run/ is suitable for root-owned processes; others may use /tmp  or /vat/tmp
# or their home directory or applicaiton filesystem.
# LOCK=/var/run/lock.myapp

LOCK=/tmp/lock.myapp
KEYFILE=/tmp/domains.txt
MYDOMAIN=$1
mydom=/tmp/${MYDOMAIN}.$$

# See kill(1) for the different signals and what they are intended to do.

trap cleanup 1 2 3 6

release_lock(){

MYPID=$1
echo "Releasing lock..."
sed -i "/^${MYPID}$/d" $LOCK
}


get_lock(){

DELAY=2
GOT_LOCK=0
MYPID=$1
while [ $GOT_LOCK -ne 1 ];do
	PID=
	while [ -s $LOCK ];do
		PID=`cat $LOCK 2>/dev/null/`
		name=`ps -o comm= -p "$PID" 2>/dev/null`
		if [ -z "$name" ];then
			echo "Process $PID has claimed the lock but is not running"
			release_lock $PID;else
			echo "Process $PID ($name) has already taken the lock:"
			ps -fp $PID | sed -e 1d
			date
			echo
			sleep $DELAY
			let DELAY="$DELAY + 1"
		
		fi
	done

		# Store our pid i the lock file.
	echo $MYPID >> $LOCK
		# If another instance also wrote to the lock, it will contain more than $$ and PID
		# PID could be blank, so surround it with quotes, otherwise it is saying "-e $LOCK" and passing no filename.
	grep -vw $MYPID $LOCK > /dev/null 2>&1
	if [ "$?" -eq 0 ];then
			# If $? is 0 then grep successfuly found something else in the file.
		echo "An error has occured, Another process has taken the lock:"
		ps -fp `grep -vw -e $MYPID -e "$PID" $LOCK`	
			# The other process can take care of itself
			# Relinquish access to the lock
			# sed -i can do this automatically
			# Back off by sleeping a random amount of time.
		sed -i "/^${MYPID}$/d" $LOCK
		sleep $((RANDOM % 5));else
		$GOT_LOCK=1
			# Claim exclusive access to the lock
		echo $MYPID > $LOCK
	fi
done

}


cleanup(){


echo "$$: Caught signal: Exiting"
release_lock
exit 0
}

# Main Script goes here
# You may want to do stuff without the lock here
# Then get the lock for the exclussive work
get_lock $$

############
##DO STUFF##
############

release_lock $$









