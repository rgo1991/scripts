#!/bin/bash

fibonacci(){

return $(( $1 + $2 ))

}

F0=0
F1=1

echo 0: $F0,
echo 1: $F1,

for count in `seq 2 17`;do
fibonacci $F0 $F1
F2=$?
if [ $F2 -lt $F1 ];then
	echo "${count}:$F2 (WRONG!)";else
	echo $count: $F2;fi

F0=$F1
F1=$F2
sleep 0.1
done

fibonacci $F0 $F1
echo $count: $?
