#!/bin/bash
# Lock is a global variable. for this usage, lock.myapp.$$ is not suitable
# /var/run is suitable for root-owned processes: others may use /tmp/ or /var/tmp
# or their home directory or application filesystems
# LOCK=/var/run/lock.myapp

LOCK=/tmp/lock.myapp
KEYFILE=/tmp/domains.txt
MYDOMAIN=$1
mydom=/tmp/${MYDOMAIN}

# see kill(1) for the different signals and what ehry are intended to do

trap cleanup 1 2 3 6

release_lock(){

MYPID=$1
echo "Releasing lock."
sed -i "/^${MYPID}$/d" $LOCK

}

get_lock(){

DELAY=2
GOT_LOCK=0
MYPID=$1

while [ "$GOT_LOCK" -ne "1" ];do
	PID=
	while [ -s $LOCK ];do
		PID=`cat $LOCK 2>/dev/null`
		name=`ps -o comm= -p "$PID" 2>/dev/null`
		if [ -z "$name" ];then
			echo Process $PID has claimed the lock but is not running
			release_lock $PID;else
		echo "Process $PID ($name) has already taken the lock"
		ps -fp $PID | sed -e 1d
		date
		echo
		sleep $DELAY 
		let DELAY="$DELAY + 1";fi
done

# Store our pid in the lock file

echo $MYPID >> $LOCK

# if anynother instance also wrote to the lock, it will contain
# more than $$ and $PID
# PID could be blank, so surround it with quotes.
# otherwise it is saying "-e $LOCK" and passing no filename

grep -vw $MYPID $LOCK > /dev/null 2>&1
if [ "$?" -eq "0" ];then
	# if $? is 0 then grep successfully found something else in the file.
	echo An error has occured. another process has taken the lock
	ps -fp `grep -vw -e $MYPID -e "$PID" $LOCK`
	# the other process can take care of itself
	# relinquish access to the lock
	# sed -i can do this atomically
	# back off by sleeping a random amount of time
	sed -i "/^${MYPID}$/d" $LOCK
	sleep $((RANDOM % 5));else
	GOT_LOCK=1
	# claim exclusive access to the lock
	echo $MYPID > $LOCK;fi
done
}

cleanup(){

echo "$$: caught signal: exiting"
release_lock
exit 0
}


# Main script goes here
# You may want to do stuff without the lock here
# Then get the lock for the exclussive work

get_lock $$

echo "$MYDOMAIN Cretion date:" | tee -a $KEYFILE
sleep 2

whois $MYDOMAIN | grep -i created | cut -d":" -f2- | tee -a $KEYFILE 
sleep 2

echo $MYDOMAIN Expiration date: | tee -a $KEYFILE
sleep 2

whois $MYDOMAIN | grep "Expiration date:" | cut -d: -f2- | tee -a $KEYFILE
sleep 2

echo $MYDOMAIN DNS Servers: | tee -a $KEYFILE 
sleep 2

whois $MYDOMAIN | grep "Name Server:" | cut -d: -f2- | grep -v "^$" | tee -a $KEYFILE
sleep 2

echo "... end of $MYDOMAIN information ..." | tee -a $KEYFILE 

echo >> $KEYFILE

# Then release the lock when you are done.
release_lock $$
# again, there may be stuff that you will want to do after the lock is released
# then cleanly exit
exit 0














