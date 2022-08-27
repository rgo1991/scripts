#!/bin/bash


stopdial(){

if [ ! -z "$DIALPID" ];then
	kill -9 $DIALPID
	unset DIALPID
	echo;fi
}

dial(){

echo -en " "
	while :;do
	echo -en "`date`"
	sleep 1;done
	echo
}

trap stopdial `seq 1 63`

echo starting...
echo "`date`: Doing something long and complicated"
dial &
DIALPID=$!
sleep 10
stopdial
echo "`date`: FInished the complicated bit. That was hard!"
echo Done
