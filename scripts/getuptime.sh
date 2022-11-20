#!/bin/bash


LOG=`date +%s`.log
touch $LOG

for i in `seq 1 5`;do
	echo "$i" >> $LOG
	let i++;done
