#!/bin/bash

lenline=$1
temp=`mktemp`
count=0


if [ $# -lt "2" ];then
	echo usage ****
elif [ $# -eq "2" ];then
	file=$2
	oIFS=$IFS
	IFS=' '
	while read -ra var;do
	for i in ${var[@]};do
		echo -n $i' '
		let count="count + ${#i}"
		if [ "$count" -ge "$lenline" ];then
			echo
			count=0;fi;done
	done < $file
	IFS=$oIFS	

else
shift
oIFS=$IFS
IFS=' '
string="$@"
# read -r = do not allow backslashes to escape any characters. raw input.
read -ra str <<< "$string"


for i in "${str[@]}";do
echo -n "$i"' '
let count="count + ${#i}"

if [ "$count" -ge "$lenline" ];then
        echo
        count=0;fi
done;fi
IFS=$oIFS
#string="$@"
#count=${#string}
#padding=$(($lenline - $count))
#echo "$string" > $temp
#count=0

#while IFS='' read var;do




#pad=" "
#for i in `seq 0 $(($padding - 1))`;do
#	pad=${pad}" ";done
#echo "${pad}"[$var]

#while [ $count -lt $lenline ];do
#	echo -en "${var}"
#	let count="count + ${#var}"
#	if [ $count -ge $lenline ];then
#	echo "\n${var}"
#	echo ;fi;done




#done < $temp
echo $count
echo $lenline

	
	
