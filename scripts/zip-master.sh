#!/bin/bash

fifo=/tmp/zips.fifo
rm $fifo
mkfifo $fifo
searchstring=$@

while read filename;do
	unzip -l $filename | grep $searchstring > /dev/null 2>&1
	if [ "$?" -ne "0" ];then
	echo Found \"$searchstring\" in $filename;fi
done < $fifo
echo Finished!
