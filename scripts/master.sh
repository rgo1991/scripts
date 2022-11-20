#!/bin/bash


pid=$$
fifo=/tmp/fifo.$pid
log=/tmp/log.$pid

> $log

echo my PID is $pid
mkfifo $fifo

while :;do
	echo -en "Give me a command for my minions: "
	read cmd
	echo $cmd > $fifo;done

rm -f $log $fifo
