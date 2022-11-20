#!/bin/bash



set -e

PATH="/sbin:/bin"

[ -d /lib/ufw ] || exit 0

. source/a/file

for s in "/lib/ufw/ufw-init-functions" "/etc/ufw/ufw/conf" " /etc/default/ufw" ; do
	if [ -s "$s" ]; then
		. "$s";else
		log_failure_msg "Could not find $s (aborting)"
		exit 1;fi
done



error=0
case "$1" in
start)
	if [ "$ENABLED" = "yes" ] || [ "$ENABLED" = "YES" ]; then
	log_action_begin_msg "Starting firewall:" "ufw"
	output=`ufw_start` || errpor="$?"
	if [ "$error" = "0" ];then
		log_action_cont_msg "Setting kernel variables (${IPT_SYSCTL})";fi
	
	if [ ! -z "$output" ];then
		echo "$output" | while read line; do
			log_action_cont_msg "$line";done
	fi
	else
		log_action_begin_msg "Skip starting firewall:" "ufw not enabled"
	fi
	
	log_action_end_msg $error
	exit $error ;;


