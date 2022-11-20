#!/bin/bash

trap may_die 1 3 9 15

may_die(){

SLEEP=`expr $RANDOM % 20`
echo "Sleeping for $SLEEP seconds (but you dont know that)"
sleep $SLEEP && exit 10

}


TIME=`expr $RANDOM % 50`
echo "Stoppping MYAPP. (likely to take $TIME seconds. but you dont know that)"

for i in `seq 1 $TIME`;do
	echo -en "."
	sleep 1
done
exit 20
