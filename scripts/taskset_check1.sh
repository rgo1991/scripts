#!/bin/bash

PROGNAME=`/bin/basename $0`

print_usage(){

	echo usage
}

check_pid(){

	pid=$1
	#cpuset=`cat /proc/$pid/cpuset`
	cpuset=""
	tasksetaffinity=`taskset -pc $pid|awk '{print $NF}'`
	#cpu=`cset set -l|egrep $cpuset'\$'|awk '{print $2}'
	cpu=""
	#memnode=`cset set -l|egrep $cpuset'\$'|awk '{print $4}'`
	memnode=""	

	arr=()
	
	# Use perl to expand out any ranges encountered
	tasksetaffinity1=`echo $tasksetaffinity | perl -pe 's/(\d+)-(\d+)/join(",",$1..$2)/eg'|sed 's/,/ /g'`
	
	IFS=' '
	for i in $tasksetaffinity1;do
		j=`cat /sys/devices/system/cpu/cpu${i}/topology/physical_package_id`
		arr+=( "$j" );done

	
	memnodes=`printf '%s\n' "${arr[@]}" |sort|uniq -c|awk '{print $1"x node"$2}'|tr '\n' ',' | sed 's/,$/\n/g'`

	paddedpid=`printf "%5s $pid"` # right pad with spaces - makes it easier to grep for that pid. oherwise grepping for 345 would have returned 345 and 12345.
	
	actual_cpu=`ps -eo pid,comm,psr|egrep "$paddedpid"|awk '{print $3}'` # can specify which tabs ps should return.
	threads=`ps -eLo pid,comm,psr|egrep $paddedpid|awk '{print $3}'|sort|uniq -c|sed -e 's/^[ ]*//'|sed -e 's/\([^ ]*\) \([^ ]*\)/\1x cpu\2/g'|tr '\n' ';'|sed 's/;$/\n'|sed 's/;/; /g'`

	printf "| %-35s | %10s | %20s | %20s | %60s|\n" "$process" "$pid" "$tasksetaffinity" "$memnodes" "$threads"

}

if [ $# -ne 1 ];then
	print_usage
	exit;fi

PROC_CONF="/opt/vela/scrits/config/proc.conf"
HOST=`hostname -s`
process=$1

printf "+ %-35s +%10s +%20s +%20s +%60s +\n" "" "" "" ""|sed 's/ /-/g'
printf "| %-35s |%10s |%20s |%20s |%60s |\n" "PROCESS NAME" "PID" "TASKSET AFFINITY" "MEMNODE(s)" "ACTUAL CPU(s)"
printf "| %-35s |%10s |%20s |%20s |%60s |\n" "" "" "" "" " (... and THREADS PER CPU)"
printf "+ %-35s +%10s +%20s +%20s +%60s +\n" "" "" "" ""|sed 's/ /-/g'



if [ "$process" == "all" ];then
	if [ -r $PROC_CONF ];then
		if [ 0 = 1 ]; then echo "$HOST config file: $PROC_CONF"; fi
	else
		echo "Warning: [$PROC_CONF] not found or not readable";fi


PROCS=`grep $HOST $PROC_CONF | grep -v "^#" | awk -F':' '{print $2}'`

OLD_IFS="$IFS"
IFS='|'

for PROC in $PROCS;do
	process=`echo $PROC | awk -F'@' '{print $1}'`
	pid=`/sbin/pidof $process`
	
	if [ "$pid" == "" ];then
		printf "| %-35s |%14s\n" "$process" "	[not running]"
		continue
	fi

	check_pid $pid
done


elif [ "$process" == "pswom" ]; then

	ps -F --User vela | grep -v "ps -F --User vela" |grep -v bash| grep -v ssh |grep -v UID > /tmp/cset_check.temp

	exec < /tmp/cset_check.temp
	while read LINE;do
		pid=`echo $LINE | cut -d ' ' -f 2`
		process=`echo $LINE | cut -d ' ' -f 11-| cut -c 1-30`
		check $pid;done

else

	process=$1
	pid=`/sbin/pidof $1`

	if [ $pid == "" ];then
		printf "| %-35s |%14s\n" "$process" "	[is not running or is not a valid process]"
		exit;fi

	check_pid $pid

fi

printf "+ %-35s +%10s +%20s +%20s +%60s +\n" "" "" "" ""|sed 's/ /-/g'








































	
	










