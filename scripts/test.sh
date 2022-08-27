#!/bin/bash
file=sampletext.txt

while read var1 ;do
	echo var1 $var1
done < $file

echo

echo $1 | while read var2;do
echo $var2;done
