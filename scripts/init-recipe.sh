#!/bin/bash


### BEGIN INIT INFO
# Provides: myapp
# Required-Start: $local-fs $network $remote_fs
# Required-Stop: $local_fs $network $remote_fs
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: start and stop myapp
# Description: MyApplication is a great utility for
#	       doing things with systems
### END INIT INFO

INSTDIR=/usr/local/bin
PIDFILE=/var/run/myapp.pid
APP=myapp
case $1 in
	start)
		if [ -f $PIDFILE ];then
			echo ERROR: $PIDFILE already exists
			exit 1;fi
		$INSTDIR/$APP &
		PID=$!
		echo $PID > $PIDFILE
		exit 0 ;;
	stop) 
		$0 status || exit 1
		PID=`cat $PIDFILE 2>/dev/null`
		if [ "$?" -eq "0" ];then
			kill -9 $PID && rm -f $PIDFILE || exit 1;else
			exit 1;fi
		exit 0 ;;
	status)
		PID=`cat $PIDFILE 2>/dev/null`
		if [ "$?" -ne "0" ];then
			if [ "`ps -o comm= -p $PID`" != "$APP" ];then
				echo ERROR: PID $PID is not $APP
				exit 1;fi
			ps -p $PID > /dev/null 2>&1
			exit $?;else
		exit 1;fi ;;
	restart)
		$0 stop && $0 start ;;
	force-reload)
		$0 restart ;;
	*)
		echo Argument \"$1\" not implemented
		exit 2 ;;
esac
	




