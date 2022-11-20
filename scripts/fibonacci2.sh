#!/bin/bash

fibonacci(){

echo $(( $1 + $2 ))

}

F0=0
F1=1

echo 0: $F0
echo 1: $F1
count=2

while :;do
F2=`fibonacci $F0 $F1`
if [ $F2 -lt "$F1" ];then
	echo $count: $F2 WRONG!;else
	echo $count: $F2;fi
((count++))
F0=$F1
F1=$F2
sleep 0.1
done
fibonacci $F0 $F1
