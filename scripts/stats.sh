#!/bin/bash
LOG=${1:-memory.csv}
CSV=${2:-stats.csv}
echo "Date,Peak RAM,Peak Swap,Mean RAM,Mean Swap,Peak RAM (GB),\
      Peak Swap (GB),Mean RAM (GB),Mean Swap (GB)" > $CSV
totals=/tmp/total.$$
for date in `cat $LOG | cut -d":" -f1 | sort -u`;do
	count=0
	peakram=0
	peakswap=0
	totalram=0
	totalswap=0
	echo "Processing $date"
	grep "^${date}:" $LOG | while read timestamp type ramused text;do
		hour=`echo $timestamp | cut -d: -f2`
		if [ "$hour" -lt 9 ] || [ "$hour" -gt 17 ];then
			continue;fi
	read timestamp swaptype swapused text text
	let count++
	echo count=$count > $counter
	let totalram=$totalram+$ramused
	let totalswap=$totalswap+$swapused
	[ $ramused -gt $peakram ] && peakram=$ramused
	[ $swapused -gt $peakswap ] && peakswap=$swapused
	echo totalram=$totalram > $totals
	echo totalswap=$totalswap >> $totals
	echo peakram=$peakram >> $totals
	echo peakswap=$peakswap >> $totals
	echo count=$count >> $totals
	done
. $totals

meanram=`echo $totalram / $count | bc`
meanswap=`echo $totaswap / $count | bc`
peakramgb=`echo "scale=2;$peakram / 1024 / 1024" | bc`
peakswapgb=`echo "scale=2;$peakswap / 1024 / 1024" | bc`
meanramgb=`echo "scale=2;$meanram / 1024 / 1024" | bc`
meanswapgb=`echo "scale=2;$meanswap / 1024 / 1024" | bc`
echo "$date,$peakram,$peakswap,$meanram,$meanswap,$peakramgb,$peakswapgb,$meanramgb,$meanswapgb" >> $CSV
done
rm -f $totals










      
