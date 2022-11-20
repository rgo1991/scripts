#!/bin/bash
###########
# Put together files containing your favorite and most useful definitions and functions
# As necessary, "include" one or more of these "library files" in scripts with either the dot (.) or source command
###########

#useful variables
ROOT_UID=0
E_NONROOT=101
MAXRETVAL=256
SUCCESS=0
FAILURE=-1




#FUNCTIONS


usage(){

if [ -z $1 ];then #no arg passsed
	msg=filename;else
	msg=$@;fi

	echo "Usage `basename $0` "$msg""

}

check_if_root(){ #check if running script as root

if [ $UID -ne "$ROOT_UI"];then
	echo "Must be root to run this script"
	exit $E_NONROOT;fi

}

CreateTempFileName(){ #creates uniqe temp filename

preffix=temp
suffix=`eval date +%s`
Tempfilename=$preffix.$suffix


}


isalpha2(){ #tests whether the entire string is alphabetic

[ $# -eq 1 ] || return $FAILURE;;

case $1 in
	*[!a-zA-Z]*|"") return $FAILURE ;;
	*) return $SUCCESS ;;
esac

}

abs(){	# absolute value

E_ANGERR=-99999

if [ -z "$1" ];then
	return $E_ANGERR;fi

if [ $1 -ge 0 ];then
	absval=$1;else	#if greater than 0 then stays the same
	let "absval = (( 0 - $1 ))";fi #otherwise change - into +
	return $absval
}

tolower(){  #Converts strings passed as arguments to lowercase

if [ -z "$1" ];then	
	echo "(null)"	#if no argument passed returns an error.
	return;fi

echo "$@" | tr A-Z a-z	#translate all passed arguments

return

#TIP: use command substitution to set a variable to function output
#EG:
#	oldvar="a set of mixed cased letters"
#	newvar=`tolower $oldvar`
#	echo $newvar


}
