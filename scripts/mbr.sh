#!/bin/bash

if [ -b $1 ];then
	mbr=`mktemp`
	echo reading MBR from device $1
	dd if=$1 of=$mbr bs=512 count=1
	mbr_is_temporary=1;else
	mbr=$1
	if [ -r "$mbr" ];then
	echo reading MBR from file $mbr;else
	echo readable MBR required
	exit 1;fi
fi


od -v -t x1 -An -j 510 $mbr | grep -q " 55 aa$"

if [ "$?" -ne "0" ];then
	echo MBR signature not found. Not a valid MBR
	exit 1;fi

partnum=1

od -v -t x1 -An -j446 -N 64 $mbr | \
while read status f1 f2 f3 parttype l1 l2 l3 lba1 lba2 lba3 lba4 s1 s2 s3 s4;do

if [ "${partype}" == "00" ];then
	echo partition $partnum is not defined;else
	case $status in
	00) bootable="unbootable";;
	80) bootable="bootable"  ;;
	*)  bootable="invalid"   ;;
	esac

	printf "Partition %d is type %02s and is %s." $partnum $parttype $bootable
	sectors=`printf "%02s%02s%02s%02s\n" $s4 $s3 $s2 $s1 | \
		 tr '[:lower:]' '[:upper:]'`
	bytes=`echo "ibase=16; $sectors /2" | bc`
	gb=`echo "scale=2; $bytes / 1000 / 1000" | bc`
	printf " Size %.02f GB\n" $gb;fi

partnum=`expr $partnum + 1`
done

if [ "$mbr_is_temporary" ];then
	rm -f $mbr;fi
