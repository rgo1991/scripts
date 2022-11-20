#!/bin/bash

file=sample.csv

while read var1;do
oIFS=$IFS
IFS=','
count=0
for i in $var1;do
        let count++;done
IFS=$oIFS

done < $file
echo $count

for i in `seq 1 $(($count))`;do
#	if [ "$i" -lt "3" ];then
#		echo -en "col$i\t\t"
#	elif [ "$i" -le "4" ];then
#		echo -en "col$i\t\t\t"
#	else
#		echo -en "col$i\t\t";fi
       if [ "$i" -eq "1" ];then
               echo -en "Last Name\t"
       elif [ "$i" -eq "2" ];then
               echo -en "First Name\t"
       elif [ "$i" -eq "3" ];then
               echo -en "Address\t\t\t"
 	elif [ "$i" -eq "4" ];then
		echo -en "City\t\t\t"
	elif [ "$i" -eq "5" ];then
		echo -en "State\t\t"
	elif [ "$i" -eq "6" ];then
                echo -en "ZIP\t\t";
	elif [ "$i" -eq "7" ];then
                echo -en "Phone Number"

fi
done

#echo -e "Name\t\tAddress\t\tCity\t\tState\tZIP\tPhoneNum"
echo
while read var2;do

echo $var2 | sed 's/,/\t\t/g'

done < $file
