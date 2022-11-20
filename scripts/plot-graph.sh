#!/bin/bash
LOG=/var/tmp/memory.log
echo "Date,Time,Memory Used,Swap Used,Gb Memory Used,Gb Swap Used"
for MEMINFO in `ls /var/tmp/*.meminfo|sort -n`;do
	timestamp=`head -1 $MEMINFO`
	memtotal=`grep "^MemTotal:" $MEMINFO | awk '{ print $2 }'`
	memfree=`grep "^MemFree:" $MEMINFO | awk '{ print $2 }'`
	swaptotal=`grep "^SwapTotal:" $MEMINFO | awk '{ print $2 }'`
	swapfree=`grep "^SwapFree:" $MEMINFO | awk '{ print $2 }'`
	ramused=$((memtotal - memfree))
	swapused=$((swaptotal - swapfree))
	date=`echo $timestamp | cut -d: -f1`
	time=`echo $timestamp | cut -d: -f2-`
	echo "$DATE Memory $ramused KB in use" >> $LOG
	echo "$DATE Swap $swapused KB in use" >> $LOG
	gbramused=`echo "scale=2;$ramused / 1024 / 1024" | bc`
	gbswapused=`echo "scale=2;$swapused / 1024 / 1024"| bc`
	echo "$date,$time,$ramused,$swapused,$gbramused,$gbswapused"
done
	
