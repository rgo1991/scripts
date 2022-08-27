#!/bin/bash


ACCEPT_LICENSE=0
echo "Reading configuration..."

CFG=`dirname $0`/etc/install.cfg
. $CFG
echo "Done."

mkdir `dirname $0`/logs 2>/dev/null || exit 1

if [ "$ACCEPT_LICENSE" -ne "1" ];then
	${PAGER:-more} `dirname $0`/LICENCE.TXT
	read -p "Do you accept the licence terms?"
	case $REPLY in
	y*|Y*) continue ;;
	    *) "You must accept the terms to install the software."
		exit 1
	esac;fi

rm -f `dirname $0`/logs/status

case `uname` in
	Linux)
		for rpm in `dirname $0`/rpms/*.rpm;do
		rpm -Uvh $rpm 2>&1 | tee `dirname $0`/logs/`basename ${rpm}`.log
		echo "${PIPESTATUS[0]} $rpm" >> `dirname $0`/logs/status;done ;;
	SunOS)
		for pkg in `dirname $0`/pkgs/*.pkg;do
		pkgadd -d $pkg 2>&1 | tee `dirname $0`/logs/status;done ;;
	*) 
		echo unsupported OS. Only RPM and PKG formats available
		exit 2 ;;
esac


echo

#check for errors... grep -v "^0 " returns 1 if there *are* any lines which start with something other than "0 "

grep -v "^0 " `dirname $0`/logs/status

if [ "$?" -ne 1 ];then
	echo Errors were encountered during installation of the above packages;else
	echo Somftware installed succesfully.;fi









