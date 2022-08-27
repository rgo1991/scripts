#!/bin/bash

regex="*?(4|5|6){2}"





for ((i=10000; i<=99999; i++));do
	echo $i| grep -qE "${regex}"
	if [ $? == 0 ];then
		echo $i;fi
done
	
