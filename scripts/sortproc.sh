#!/bin/bash
# Script that takes a process file (proc.conf in this case) and parses it.
# It takes the servers and puts them into an array.
# Then uses that array to make another array whose values are delimited by the server and a blank line.
# All the processes between the server name and the blank line go into the new array.
# Then parse that new array a bit to get just the required processes and do whatever work you need on them. 


TEMPFILE=mktemp
PROC_FILE=proc.conf
SERVERS=`grep "pld" $PROC_FILE | awk -F: '{print $1}'`
PROCESSES=`cat $PROC_FILE | awk -F: '{print $2}'`

#below function i stole from the morning checks in vela. it just pads the output with ---[$2]. the usage is pad $1 $2. the outcome is "$1---------[$2]" with the total lenght always 50 chars
function pad {
   j=$1
   i=`expr length $j`
   while [ $i -lt 50 ];
   do
     j=$j"-"
     let i++
   if [ $i -eq 50 ];
   then
      j=$j[$2]
   fi
   done
   echo " "$j
}

#below array parses the proc.conf to give only the server names and uses them as elements for the $server[@] array. The final grep is what greps the servers
servers=( $(cat -s ${PROC_FILE//netprobe.linux_64|} | tr "|" "\n" | sed "s/^pld/\npld/g" | awk -F@ '{print $1}' | grep -v '#'| sed -e "s/\n/,/g" -e "s/:/\n/g" | grep "^pld") )


for i in ${servers[@]};do
	
	#bellow sets the ${array[@]} to contain information starting from server name ($i) until the next blank line. The final sed is what does the main job.
	array=( $(cat -s ${PROC_FILE//netprobe.linux_64|} | tr "|" "\n" | sed "s/^pld/\npld/g" | awk -F@ '{print $1}' | grep -v '#'| sed -e "s/\n/,/g" -e "s/:/\n/g" |  sed -n "/$i/,/^$/p") )
	echo ${array[0]} #but it would be ssh not echo to ssh into each server individually
		for j in `seq 1 $((${#array[@]}))`;do #for loop for doing work on all elements exluding the first one which is the server name and the nsd|siteserver|netprobe|<blankline>
			[[ ${array[$j]} == nsd ]] || [[ ${array[$j]} == siteserver ]] || [[ ${array[$j]} == netprobe* ]] || [[ ${array[$j]} == "" ]] && continue 
			#pad ${array[$j]} checked;done
			echo ${array[0]}.${array[$j]}
			#in VELA environment instead of echo it would be anything that you want to do with the processes on the server, such as check their status:
			#status=`wadmin ${array[$j]} status | grep *live | awk '{print $4}'
			#if [ $status != "Normal" ];then
			#echo The status of process ${array[$j]} on server ${array[0]} is not set to Normal. Please investigate >> $TEMPFILE;done
			#above echo could be the 'pad' function instead. 
		done
		echo
done





