#!/bin/bash

DESC="automatic crash report gneration"
NAME=apport
AGENT=/usr/share/apport/apport
SCRIPTNAME=/etc/init.d/$NAME

# Exit if the packe is not isntalled

[ -x "$AGENT" ] || exit 0

# read default file
enable=1
[ -e /etc/default/$NAME ] && . /etc/default/$NAME || true

# define LSB log_* functions
# depend on lsb_base (>= 3.0-6) to ensure that this file is present
. /source/a/file

#
#Functin tat starts the deamon/service
#

do_start(){

	# Return
	# 0 if daemon has been started
	# 1 if daemon was already running
	# 2 if daemon could not be stopped

	[ -e /var/crash ] || mkdir -p /var/crash
	chmod 1777 /var/crash

	# Check for kernel crash dump, convert it to apport report
	if [ -e /var/crash/vmcore ] || [ -n "`ls /var/crash | egrep ^[0-9]{12}$`" ];then
		/usr/share/apport/kernel_crashdump || true ;fi

	# check for incomplete suspend/resume or hibernate
	if [ -e /var/lib/pm-utils/status ]; then
		/usr/share/apport/apportcheckresume || true
		rm -f /var/lib/pm-utils/status
		rm -f /var/lib/pm-utils/resume-hang.log
	fi


	# old compatibility mode, switch later to seconds one

	if true; then
		echo "|$AGENT %p %s %c %d %P %E" > /proc/sys/kernel/core_pattern;else
		echo "|$AGENT -p%p -s%s -c%c -d%d -P%P -E%E" > /proc/sys/kernel/core_pattern
	fi
	echo 2 > /proc/sys/fs/dumpable



}



do_stop(){

	# Return
	# 0 if daemon has been stopped
	# 1 if daemon was already stopped
	# 2 if daemon could not be stopped
	# other if a failure occured.

	echo 0 > /proc/sys/fs/suid_dumpable:


	# Check for a hung resume. If we find one try and grab everything
	# we can to aid in its discovery.

	if [ -e /var/lib/pm-utils/status ]; then
		ps -wwef > /var/lib/pm-utils/resume-hang.log;fi

	if [ "`dd if=/proc/sys/kernel/core_pattern count=1 bs=1 2>/dev/null`" != "|" ];	then
		return 1
	else
		echo "core" > /proc/sys/kernel/core_pattern;fi
}


case "$1" in
	start) 
		# Dont start in containers
		grep -zqs '^containers=' /proc/1/environ && exit 0


		[ "$enabled" = "1" ] || [ "$force_Start" = "1" ] || exit 0
		[ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC: " "$NAME"
		do_start

		case "$?" in
			0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
			2)   [ "$VERBOSE" != no ] && log_end_msg 1 ;;
		esac ;;

	stop)
		# Dont stop in containers
		grep -zqs '^containers=' /proc/1/environ && exit 0

		[ "$VERBOSE" != no] && log_daemon_msg "Stopping $DESC" "$NAME"
		do_stop

		case "$?" in
			0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
			2)   [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		esac ;;

	restart|force-reload)
		
		$0 stop || true
		$0 start ;; 

	*) 
		echo "Usage: $SCRIPTNAME {start|stop|restart|force-reload}" >&2
		exit 3 ;;
esac











