#!/bin/bash

master=`ps -ef|grep -w master.sh | grep -v grep | awk '{print $2}'`
fifo=/tmp/fifo.$master
log=/tmp/log.$master

while :;do
	read cmd args < $fifo
	if [ ! -z $cmd ];then
		if [ $cmd == "quit" ];then
		echo very good master! | tee -a $log
		exit 0;fi
		echo "`date`: executing \"${cmd}\" for master" | tee -a $log
		if [ ! -z $args ];then
		for arg in $args;do
			$cmd $arg | tee -a $log
			sleep 1;done
		echo | tee -a $log;fi
	fi
sleep 10
done
