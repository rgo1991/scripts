#!/bin/bash


MD5=`mktemp /tmp/md5.XXXXX`
SAMEFILES=`mktemp /tmp/samefiles.XXXXX`
matches=0
comparisons=0
VERBOSE=1
SIZE=""
DIR=`pwd`
diff=0

logmsg(){

if [ "$VERBOSE" -ge "$1" ];then
	shift
	echo "$@";fi
}

cleanup(){

echo "Caught signal - cleaning up"
rm -f ${MD5} ${SAMEFILES} > /dev/null
exit 0

}

usage(){

echo "Usage: `basename $0` [ -e ] [ -v verbosity ] [ -d directory ]"
echo " -e ignores empty files "
echo " -v sets verbosity from 0 to 9"
echo " -c actually checks the files"
exit 2
}


while getopts 'ev:l:cd:' opt;do
	case $opt in
	e) SIZE=" -size +0 " ;;
	v) VERBOSE=$OPTARG ;;
	d) DIR=$OPTARG ;;
	c) diff=1 ;;
	esac;done



trap cleanup 1 2 3 6 9 11 15
logmsg 3 "`date`: `basename $0` starting"
kickoff=`date +%s`

#make sure that temporary files can be created.

touch $MD5 || exit 1
start_md5=`date +%s`

logmsg 3 "`date`: Gathering MD5 SUMs Please Wait"
find ${DIR} $SIZE -type f -exec md5sum {} \; |sort > $MD5

#md5sum `find ${DIR} ${SIZE} -type f -print` > $MD5
#cutting out find is a lot faster, but limited to a few thousand files

done_md5=`date +%s`
logmsg 3 "`date`: MD5 SUMS gathered. Comparing results..."
logmsg 2 "md5sum took $(($done_md5 - $start_md5)) seconds"
uniq -d -w32 $MD5 | while read md5 file1;do
logmsg 1 "Checking $file1"

grep "^${md5} " $MD5 | grep -v "^${md5} .${file}$"| cut -c35- > $SAMEFILES
cat $SAMEFILES | while read file2;do
	duplicate=0
	if [ "$diff" -eq "1" ];then
	diff "$file1" "$file2" > /dev/null
	if [ "$?" -eq "0" ];then
	duplicate=1;else
	duplicate=2;fi
	else
	duplicate=1;fi

	case $duplicate in
	0) ;;
	1) 
		if [ "$VERBOSE" -gt "5"];then
		echo "$file2 is duplicate of $file1"
		else
		echo $file2;fi 
		;;
	2) echo $file1 and $file2 have the same md5sum ;;
	esac;done
done

endtime=`date +%s`
logmsg 2 "total elapsed time `expr $endtime - $kickoff` seconds"
logmsg 2 "`date`: Done. `basename $0` found $matches matches in $comparisons comparisons"
logmsg 2 "Compared `wc -l $MD5 | awk '{ print $1 }'` files; that makes for $combinations combinations"
rm -f ${MD5} > /dev/null
