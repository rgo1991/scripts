#!/bin/bash

SAVEDIR=/tmp/log/save
mkdir -p ${SAVEDIR}
cd /var/log
NOW=`date +%d%b%Y%H%M%S`
mkdir -p "$SAVEDIR" 2>/dev/null

for FILE in messages syslog dmesg deamon.log;do
	md5sum $FILE | cut -d" " -f1 > "$SAVEDIR/$FILE.md5";done

while :;do
	NOW=`date +%d%b%Y%H%M%S`
	for FILE in messages syslog dmesg deamon.log;do
		prev=`cat $SAVEDIR/$FILE.md5 || echo 0`
		if [ -s ${FILE} ];then
		# it exists and has content
		md5=`md5sum ${FILE}| cut -d" " -f1 | tee $SAVEDIR/$FILE.md5`
		if [ $prev != $md5 ];then
			case $prev in
			0) echo "`date`: $FILE appeared" ;;
			*) echo "`date`: $FILE changed"  ;;
			esac
		cp $FILE $SAVEDIR/$FILE.$NOW;fi
		else 
		# it doesnt exist; did it exist before?
		if [ "${prev}" != 0 ];then
		echo "`date`: $FILE dissapeared"
		echo 0 > "$SAVEDIR/$FILE.md5";fi
		fi;done
		sleep 30;done
