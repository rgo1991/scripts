#!/bin/bash
count=1
while :;do
	date +%D:%H:%M > /var/tmp/$count.meminfo
	cat /proc/meminfo >> /var/tmp/$count.meminfo
	((count++))
	sleep 20
done
