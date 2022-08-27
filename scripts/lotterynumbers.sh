#!/bin/bash

declare -a lotterynumbers
number=
count=1

duplicates(){
dup=0
for i in ${#lotterynumbers[@]};do
	if [[ "$number" == "${lotterynumbers[$i]}" ]];then
		let dup++;else
		continue;fi;done

#if [[ "${lotterynumbers[*]}" =~ $number ]];then
#	return 444;fi
#if [[ ! "${lotterynumbers[*]}" =~ $number ]];then
#       return 0;fi

}
func(){
        number=$RANDOM
	if [ "$number" -le 50 ];then
		duplicates
		if [ "$dup" -eq 0 ];then
			lotterynumbers[${#lotterynumbers[@]}]=$number
			let count++
			func
		else
			func
		fi
	fi
}

while [ "$count" -le 5 ];do
#	number=$RANDOM
#	if [ "$number" -le 50 ];then
#		lotterynumbers[${#lotterynumbers[@]}]=$number
#		let count++
#		func;else
#		func;fi
func	
done

echo lottery numbers : ${lotterynumbers[@]}


