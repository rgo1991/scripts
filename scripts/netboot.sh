#!/bin/bash

TFTPBOOT=/tftpboot/linux-install/pxelinux.cfg
NFS=/kickstart
CLIENT=`getent hosts $1 | awk '{ print $2 }'`
if [ -z "$CLIENT" ];then
	echo a failure occured in looking up \"$1\"
	exit 2;fi

SERVER=`hostname`
OSNAME=RHEL60

calc_client_details(){

CLIENT_IP=`getent hosts $CLIENT | awk '{print $2}'`
if [ -z $CLIENT_IP ] || [ -z $CLIENT ];then
	echo a failure has occured in looking up \"$CLIENT\"
	exit 2;fi

# 192.168.1.42 is C0 A8 01 2A is hexadecimal format

CLIENT_HEXADDR=$(printf "%02X%02X%02X%02X" `echo $CLIENT_IP | tr '.' ' '`)
if [ "`echo -n $CLIENT_HEXADDR | wc -c`" -ne "8" ];then
	echo an error has occured processing the hex ip address for \"$CLIENT\"
	echo IPV4 address detected $CLIENT_IP
	echo Hex IP address calculated $CLIENT_HEXADDR
	exit 1;fi
	
	echo client details: $CLIENT is at ip address $CLIENT_IP ($CLIENT_HEXADDR)
}

create_pxelinux_file(){

cat - > ${TFTBOOT}/${CLIENT_HEXADDR} <<-EOF


	default boot
	timeout 600
	prompt 1
	display messages/${CLIENT}.txt
	F1 messages/$CLIENT.txt
	F2 messages/${CLIENT}-F2.txt
	label boot
	  localboot 0
	label install
	  kernel ${OSNAME}/vmlinuz
	  append initrd=${OSNAME}/initrd.img ks=nfs:${SERVER}:${NFS}/$CLIENT.cfg
	EOF

ls -ld ${TFTBOOT}/$CLIENT_HEXADDR

}

create_kickstart(){

mkdir -p ${NFS}
if [ $? -ne "0" ];then
	echo ERROR creating ${NFS}
	exit 1;fi

cat - > $NFS/${CLIENT}.cfg <<-EOF
	#kickstart file for $CLIENT to boot from $SERVER
	text install
	# you would probably want to put more details here
	# but this is a shells cripting recipe not a kickstart recipe
	%post
	echo this is the postinstall routine
	printf "10.2.2.2\ttimeserver" >> /etc/hosts
	/net/$SERVER/$NFS/${CLIENT}.postinstall
	EOF
ls -ld ${NFS}/${CLIENT}.cfg

}

create_msgs(){

CLIENTFILE=${TFTBOOT}/messages/client.txt
CLIENTF2=${TFTBOOT}/messages/client-f2.txt
MYFILE=${TFTBOOT}/messages/${CLIENT}.txt
MYF2=${TFTBOOT}/messages/${CLIENT}-f2.txt

if [ ! -r "$CLIENTFILE" ];then
	echo Error reading $CLIENTFILE
	exit 1;fi

sed s/CLIENT_NAME_HERE/$CLIENT/g $CLIENTFILE | \
sed s/SERVER_NAME_HERE/$SERVER/g | \
sed s/OSNAME/$OSNAME/g > ${MYFILE}

sed s/CLIENT_NAME_HERE/$CLIENT/g $CLIENTF2 | \
sed s/SERVER_NAME_HERE/$SERVER/g > ${MYF2}

ls -ld $MYFILE
ls -ld $MYF2

}

calc_client_details
create_msgs
create_kickstart
create_pxelinux_filee































