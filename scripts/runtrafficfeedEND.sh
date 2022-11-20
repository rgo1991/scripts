#!/bin/bash

# Use this file to run interacive console applications which will only terminate with crtl-c

if [ `hostname -s` == "wtwommnp01" ];then
	echo "!! Cannot run market data check from wtwommnp01"
	exit 0 
fi

wombatpath="/opt/wombat"

cd $wombatpath/apis_ent/client_profiles
wombatbin="$wombatpath/apis/bin"

echo " "
echo "      ###################################################"
echo "                     Subscription Checks"
echo "      ###################################################"
echo " "


# import entitled profile
. /opt/wombat/apis_ent/client_profiles/profile.fxcm_ny2
commandstorun="mamalistenc -S ICEMDFMCEU -tport icemdfmceu -s CH21.IR
mamalistenc -S CMEMDP -tport cmemdp -s CLX1
mamalistenc -S OPTIQDERIV -tport xlif -s FCEF1
mamalistenc -S HKFEOMD -tport hkfeomd -s HHIM1
mamalistenc -S BME -tport bme -s FIBXZ0
mamalistenc -S CEF -tport cefeurex -s FDAX_JUN21
mamalistenc -S CBOECSM -tport cboecsm -s VAJ21"

secondstorun=4

if [ -x /bin/mktemp/ ];then
	tempdiff=`/bin/mktemp /tmp/check_tmp.XXXXXXXXXXX`;else
	tempdiff=`date %H%M%S`
	tempdio "##############################################################################"
echo " FXCM GLOBAL SERVICES NY2 Entitlements "
echo "##############################################################################"
echo ""f=`/tmp/check_tmp.${tempdiff}`
	touch $tempdiff
	chmod 600 $tempdiff
fi

echo "##############################################################################"
echo " FXCM GLOBAL SERVICES NY2 Entitlements "
echo "##############################################################################"
echo ""


echo -e "$commandstorun" | while read command; do
	echo "" > $tempdiff
	formattedcommand="$command"
	
	$formattedcommand &>$tempdiff &
	myPID=$!
	sleep $secondstorun
	kill ${myPID}
	count=`cat $tempdiff | grep "STATUS OK" | wc -l`
	if [ "$count" \> 0 ];then
		echo -e "$formattedcommand: INFO-($count) STATUS OK MESSAGES";else
		echo -e "$formattedcommand: **********CRITICAL********** - (0) STATUS OK MESSAGES"
	fi

done 2> /dev/null

echo ""
rm -f $tempdiff
























