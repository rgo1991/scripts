#!/bin/bash

stopdial(){

if [ ! -z $DIALPID ];then
	kill -9 $DIALPID
	unset DIALPID
	echo -en "";fi
}

dial(){

dial=('/' '-' '\' '|' '/' '-' '\' '|')
echo -en " "
d=0
while :;do
	echo -en "${dial[$d]}"
	d=$(($d + 1))
	let "d=$d % 8"
	sleep 1;done
	echo
}

trap stopdial `seq 1 63`

echo starting...
echo "`date`: Doing something complicated and long"
echo -en here is a dial to keep you amused

dial &
echo
DIALPID=$!
sleep 10
echo
stopdial
echo "`date`: Fininshed doing something complicated, that was hard."
echo Done

