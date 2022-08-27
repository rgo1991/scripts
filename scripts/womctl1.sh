#!/bin/bash

export WMW_IBV_SW_CKSUM=1
ALLOWED_USER="vela"
LOG=$WOMBAT_LOGS/womctl.log
NSD_CONF=$SCRIPTS_HOME/config/nsd.conf
PROC_CONF=$SCRIPTS_HOME/config/proc.conf
HOST=`hostname -s`

# allow double the default open files
ulimit -n 2048

if [ "$USER" != "$ALLOWED_USER" ];then
	echo "[`basename $0`] This script may only be xecuted by the user [$ALLOWED_USER] not [$USER]"
	exit 1;fi

print_who(){

whoami| awk '{print "["$1"|"$2"|"$3"-"$4" "$5"|"$6"]"}' | sed 's/[(,)]//g'
}

printtime(){
date +"%Y-%m-%d %T"
}

usage(){
echo "[`basename $0`] Usage: /etc/init.d/womctl start <proc>" 1>&2
echo "[`basename $0`] or: /etc/init.d/womctl stop <proc> [<proc>...]" 1>&2

}

parse_taskset(){

program=`echo $1 | awk -F'@' '{print $1}'`
taskset_str=""
cpuset_str=`echo $1 | awk -F'@' '{print $2}'`
}


check_v5(){
echo $1 | awk -F'_' '{print $2}'
}

check_v5_cache(){
echo $1 | awk -F'_' '{print $1"_"$2}'

}

check_sb(){
echo $1 | awk -F'_' '{print $1}'

}

pidlist(){
	if [ x`uname -s` == "xSunOs"];then
		ps -ef -o "pid comm" | sed 's/[^/ ]*\///g' | grep -w $1 | sed -e 's/^ *//' -e 's/ .*//';else
		ps -eF | grep -w ${1} | grep -v 'grep' | grep -v 'womctl' | awk '{print $2}' | sed -e 's/^ *//' -e 's/ .*//';fi
}


# Function to kill the named processes.

kill_proc(){

	pid=`pidlist $1`
	[ "$pid" != "" ] && kill $pid
	if [ "$pid" != "" ];then
		echo "[`basename $0`] `printtime`:`printwho`: killing [$1] with PID [$pid]" >> $LOG;else
		echo "[`basename $0`] `printtime`:`printwho`: [$1] not running" >> $LOG;fi
}

echo "[`basename $0`] `printtime`:`printwho`: Command [womctl $*]" >> $LOG


start_() {

	parse_taskset $2
	
	is_v5=`check_v5 $2`
	is_v5_cache=`check_v5_cache $2`
	is_sb=`check_sb $2`

	pid=`pidlist $program`

	if [ "$pid" != "" ] && [ "$2" != 'all' ];then
		echo "[`basename $0`] $program: already running" >&2
		echo "[`basename $0`] `printtime`:`printwho`: [$program] already running" >> $LOG
		return 1
	fi

	if [ -n $WOMBAT_LOGS -a -d "$WOMBAT_LOGS"];then
		cd $WOMBAT_LOGS;fi
		
	case "$2" in
		'siteserver'*)
			program="siteserver.sh"
			site="`echo "${2}" | awk -F'_' '{print $2}'`"
			shift 2
			args="$*"

			if [ "`echo $args | sed 's/ //g'`" == "" ];then
				args="-start -config_dir $ENTS_HOME/config/sites/$site -install_dir $ENTS_HOME";fi

			echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args [$args]" >> $LOG
			echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args [$args]" >> $WOMBAT_LOGS/$program.stder.log
			$program $args >> $WOMBAT_LOGS/$program.stderr.log 2>&1 &
		 ;;

		'nagios'*)
			program=$2
			shift 2
			args="$*"
			
			if ["`echo $args | sed 's/ //g'`" == "" ];then
				args="-d $NAGIOS_HOME/config/nagios.cfg";fi

		        echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args]" >> $LOG
		        echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args]" >> $WOMBAT_LOGS/$program.stderr.log
			$program $args >> $WOMBAT_LOGS/$program.stderr.log 2>&1 &
		;;

		'all')
			PROCS=`grep $HOST $PROC_CONF | grep -v "^#" | awk -F':' '{print $2}'`
			
			OLD_IFS="$IFS"
			IFS='|'

			for i in PROCS;do
				echo "[`basename $0`] Starting [$PROC]"
				IFS="$OLD_IFS"
				start "start" $PROC
				sleep 3
				IFS='|';done
			IFS="$OLD_IFS"
		;;
			









	


}




































