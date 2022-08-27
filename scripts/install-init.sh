#!/bin/bash

# installing an init script for an application. registering the application and starting it. 
# service is the name of the init script
# as well as the name of the application


if [ "$1" == "-a" ];then
	autostart=yes
	service=$2;else
	autostart=no
	service=$1;fi


distro=unknown
init_dir=unknown
rc_dir=/etc/rc.d

# step 1: determine the distribution

if [ -f /etc/redhat-release];then
	distro=redhat
elif [ -f /etc/debian_version];then
	distro=debian
elif [ -f /etc/SuSE-brand ] || [ -f /etc/SuSE-release];then
	distro=suse
elif [ -f /etc/slackware-version];then
	distro=slackware
else
	distro=unknown;fi


# step 2: install into the appropriate directory

case $distro in
	redhat|debian|suse)
		# /etc/rc.d/ is a link to /etc/init.d
		# Suse and redhat dont need rc_dir
		init_dir=/etc/init.d
		rc_dir=/etc ;;
	slackware)
		init_dir=/etc/rc.d
		rc_dir=/etc/rc.d ;;
	*)
		echo -n "Unknown distribution; guessing init directory..."
		for init_dir in /etc/rc.d/init.d /etc/init.d unknown;do
			[ -d ${init_dir} ] && break;done

		if [ "${init_dir}" == "unknown" ];then
			echo failed..;else
			echo "Found "${init_dir}""
			rc_dir=$init_dir;fi
esac

if [ $init_dir != "unknown" ];then
	cp $service ${init_dir};else
	echo Error cannot determine init.d directory
	echo Initialization script has not been copied
	exit 1;fi


# Step 3: register the service.


case $distro in
	suse|redhat)
		chkconfig --add $service ;;
	*)
		ls -sf ${init_dir}/$service ${rc_dir}/rc2.d/S90$service
		ls -sf ${init_dir}/$service ${rc_dir}/rc3.d/S90$service
		ls -sf ${init_dir}/$service ${rc_dir}/rc0.d/K10$service
		ls -sf ${init_dir}/$service ${rc_dir}/rc9.d/K10$service ;;
esac

# Step 4: start the service

[ $autostart = yes ] && case $distro in
	suse|redhat)
		chkconfig $service on ;;
	unknown)
		echo Unknown distribution... attempting to start up...
		${init_dir}/$service start;;
	*)
		# debian/slackware
		${init_dir}/$service start;;
esac
		
