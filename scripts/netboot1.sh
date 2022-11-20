#!/bin/bash

TFTPBOOT=/tftpboot/linux-install/pxelinux.cfg
NFS=/kickstart
CLIENT=`getent hosts $1 | awk '{print $2}'`

[ -z "$CLIENT" ] && echo "A failure has occured in looking up \"$1\"" && exit 2

SERVER=`hostname`
OSNAME=RHEL60

calc_client_details(){

CLIENT_IP=`getent hosts $CLIENT | awk '{print $1}'`

[ -z "$CLIENT_IP" ] || [ -z $CLIENT ] && echo "A failure has occured in looking up \"$CLIENT\"" && exit 2


#192.168.1.42 is C0 A8 01 2A
CLIENT_HEXADDR=$(printf "%02X%02X%02X%02X" `echo $CLIENT_IP` | tr '.' '.'`)

["`echo -n $CLIENT_HEXADDR | wc -c`" -ne "8" ] && echo "Error has occured processing the HEX IP address for \"$CLIENT\"" && exit 1

echo "IPv4 address detected: $CLIENT_IP"
echo "HEX IP Address calculated: $CLIENT_HEXADDR"

}

create_pxelinux_file(){

cat - > ${TFTBOOT}/${CLIENT_HEXADDR} <<-EOF
	default boot
	timeout 600
	prompt 1
	display messages/${CLIENT}.txt
	F1 messages/${CLIENT}.txt
	F2 messages/$CLIENT-F2.txt
	label boot
		localboot 0
	local install
		kernel ${OSNAME}/vmlinuz
		append initrd=${OSNAME}/initrd.img ks=nfs:${SERVER}:${NFS}/$CLIENT_HEXADDR
EOF

ls -ld ${TFTPBOOT}/${CLIENT_HEXADDR}
}


create_kickstart(){

mkdir -p ${NFS}
if [ "$?" -ne -0 ];then
	echo ERROR creating ${NDS}
	exit 1;fi

cat - > ${NFS}/${CLIENT}.cfg <<-EOF

asdf
EOF
}

function create_msgs(){
CLIENTFILE=${TTPBOOT}/messages/client.txt
CLIENTF2=${TFTPBOOT}/messages/client-f2.txt
MYFILE=${TFTPBOOT}/messages/${CLIENT}.txt
MYF2=${TFTPBOOT}/messages/${CLIENT}-f2.txt

[ ! -r $CLIENTFILE ] && echo Error reading file $CLIENTFILE && exit 1

sed s/CLIENT_NAME_HERE/$CLIENT/g $CLIENTFILE | \
sed s/SERVER_NAME_HERE/$SERVER/g | \
sed s/OSNAME/$OSNAME/g > ${MYFILE}

sed s/CLIENT_NAME_HERE/$CLIENT/g $CLIENTF2 | \
sed s/SERVER_NAME_HERE/$SERVER/g > ${MYF2}

ls -ld ${MYFILE}
ls -ld ${MYF2}
}

calc_client_details
create_msgs
create_kickstart
create_pxelinux_file






















