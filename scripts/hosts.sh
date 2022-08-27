#!/bin/bash


for subnet in `seq 10 10 40`;do
	case $subnet in
	10) suffix=prod
	    description=Production ;;
	20) suffix=bkp
	    description=Backup 	   ;;
	30) suffix=app
	    description=Application;;
	40) suffix=hb
	    description=HeartBeat  ;;
	esac
	cat - << EOF > /tmp/hosts.$subnet
	
	# subnet 192.168.${subnet}.0/24
	# this is the $description subnet
EOF

	for address in `seq 30 35`;do
		# for production nwetork also add the raw node name
		if [ $suffix == "prod" ];then
			printf "192.168.%d.%d\tnode%03\tnode%03d-%s\n" \
			$subnet $address $address $address $suffix >> /tmp/hosts.$subnet;else
			printf "192.168.%d.%d\tnode%03d-%s\n" \
			$subnet $address $address $suffix >> /tmp/hosts.$subnet;fi
	done
	cat /tmp/hosts.$subnet
done

