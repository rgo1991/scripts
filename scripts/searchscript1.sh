#!/bin/bash

#exec > >(tee -a log.out)
#Directoriesi
TEMP=`mktemp`

CONFIG="/opt/wombat/feeds/config"
SSCONFIG="/opt/wombat/feeds/config/site-specific/ny2/stag"
#SSCONFIG="/opt/wombat/feeds/config/site-specific/ny2/prod"
PROCCONF="/opt/wombat/scripts/config/proc.conf"

func_source(){

SOURCE=$1
CACHE_FILES=`grep $1 $SSCONFIG/mamacache_* | awk -F: '{print $1}' | sort -u`
#FEED_NAMES=`grep -A1 WmwSource rn5/*.xml | grep -w $SOURCE | sort -u | awk -F. '{print $1}'`

[ -z "$CACHE_FILES" ] && echo "Couldn't find source "$SOURCE". Try again."


for i in $CACHE_FILES;do

#	if [[ $i == "rn4/mamacache_source.xml" ]];then
#	echo ------ Feeds and their hostnames associated with source $SOURCE from $i ------                                                                            
#	grep $SOURCE rn4/mamacache_source.xml | grep Value |awk -F. '{print $3,$4,$5}'
#	continue;fi

	CACHE=`cat $i | grep mamacache | grep -v Value | sed s/"\<Name\>"/""/g | tr -d '<>/ ' | awk '{print $1}'`
	echo ------ Mamacaches and their hostnames associated with source $SOURCE from $i ------


	for j in $CACHE;do

	cache_host=( $(grep -w $j $PROCCONF| grep -v '#' |awk -F: '{print $1}') )
	
	case $SOURCE in
	AMEX) echo $j is on hosts ${cache_host[0]} and ${cache_host[1]}| egrep "amex"  ;; 
	NYSE) echo $j is on hosts ${cache_host[0]} and ${cache_host[1]}| grep 'nyse'| grep 'pny'  ;;
	*) echo $j is on hosts ${cache_host[0]} and ${cache_host[1]}|grep "pny"  ;;
	esac;done


done


FEED_NAMES=`grep -A1 WmwSource $CONFIG/*.xml | grep -w $SOURCE | sort -u | awk -F. '{print $1}'`
[ -z $FEED_NAMES ] && echo "Couldn't find source "$SOURCE". Try again."


for g in $FEED_NAMES;do
	
	echo ------ Feeds and their hostnames associated with source $SOURCE -----
	grep "$g" $PROCCONF| egrep -v "pny2sfmc|\#" | tr '|' "\n" |tr ':' "\n" |egrep "$g|pny2sffhr"| cut -d@ -f1 | sed s/':nsd'/" "/gi | column -t;done

}





func_feed(){

FEED=$1

FEED_FILES=`grep $FEED $CONFIG/* | awk -F: '{print$1}'| grep -v old |sort -u`
#[ -z $FEED_FILES ] && echo "Couldn't find feed "$FEED". Try again."




case $FEED in
	cta_amex*)SOURCE_NAMES=( $(grep -A2 WmwSource $FEED_FILES | grep Value| sed s/Value//g| tr -d '<>/' | awk '{print$2}'| sort -u | grep AMEX) ) ;;
	cta_nyse*)SOURCE_NAMES=( $(grep -A2 WmwSource $FEED_FILES | grep Value| sed s/Value//g| tr -d '<>/' | awk '{print$2}'| sort -u | grep NYSE) ) ;;
		*)SOURCE_NAMES=( $(grep -A2 WmwSource $FEED_FILES | grep Value| sed s/Value//g| tr -d '<>/' | awk '{print$2}'| sort -u) ) ;;
esac
cd ..
func_source ${SOURCE_NAMES[@]}

}

while getopts ":f:s:" arg;do
	case $arg in
		f) feed=${OPTARG} 
		   func_feed $feed ;;
		s) source_name=${OPTARG}
		   func_source $source_name ;;
		":") case $OPTARG in
			f) echo "Please specify a feed:"
			   echo "Usage: `basename $0` [-f <feedname>]" ;;
			s) echo "Please specify a source:"
			   echo "Usage: `basename $0` [-s <source_name>]" ;;
			*) echo "ERROR: unexpected parsing error occured" ;;
		     esac
		     exit 2
	esac;done


