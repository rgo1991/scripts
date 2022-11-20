#!/bin/bash
#
# Number of days between two dates
# Usage `basename $0` [M]M/[D]D/YYYY [M]M/[D]D/YYYY

ARGS=2			# Two command line parameters expected
E_PARAM_ERR=65		# Parameter error

REFYR=1600		# Reference year
CENTURY=100
DIY=365
ADJ_DIY=367		# Adjusted for leap year + fraction
MIY=12
DIM=31
LEAPCYCLE=4

MAXRETVAL=255		# Largest permissable positive return value from a function

diff=			# Declare global variable for date difference
value=			# Declare global variable for absolute value
day=			# Declare globals for day, month, year.
month=
year=



Param_error(){


echo "Usage: `basename $0` [M]M/[D]D/YYYY [M]M/[D]D/YYYY"
echo "		(date must be after 1/3/1600)"
echo $E_PARAM_ERR


}


Parse_date(){

month=${1%%/**}
dm=${1%/**}
day=${dm#*/}
let "year = `basename $1`" # Not a filename but works just the same. cuts 11/9/1991 to just 1991.

}

check_date(){		# Check for invalid dates passed

[ $day -gt $DIM ] || [ $month -gt $MIY ] || [ "$year" -lt "$REFYR" ] && Param_error

}

strip_leading_zero(){	# Strip possible leading zeros from day and/or month since otherwise Bash will interpret them as octal values (POSIX 2)

val=${1#0}
return $val

}

day_index(){		# Gauss' Formula , days from Jan 3 1600 to date passed as param.

day=$1
month=$2
year=$3

let "month = $month -2"
if [ $month -le 0 ];then
	let "month += 12"
	let "year -= 1";fi

let "year -= $REFYR"
let "indexyr = $year / $CENTURY"

let "Days = $DYI*$year + $year/$LEAPCYCLE - $indexyr + $indexyr/$LEAPCYCLE + $ADJ_DIY*$month/$MIY +$day - $DIM"
# For an in-depth explanation of this algorithm, see http://home.t-online.de/home/berndt.schwerdtfeger/cal.htm

if [ $Days -gt $MAXRETVAl ];then		# If greater than 256 then change to negative value, which can be returned from function.
	let "dindex = 0 - $Days";else
	let "dindex = $Days";fi

return $dindex

}


calculate_difference(){			# Difference between to day indices

let "diff = $1 - $2"			# Global variable

}


abs(){					# Absolute value. Uses global value variable.
					
if [ $1 -lt 0 ];then
	let "value = 0 -$1";else	# If negative then change sign, else leave it alone.
	let "value = $1";fi


}


[ $# -ne $ARGS ] && Param_error

Parse_date $1
check_date $day $month $year 		# See if valid date

strip_leading_zero $day			# Remove any leading zeroes on day and/or month
day=$?
strip_leading_zero $month
month=$?


day_index $day $month $year
date1=$?

abs $date1				# Make sure its positive by getting absolute value
date1=$value

Parse_date $2
check_date $day $month $year

strip_leading_zero $day
day=$?
strip_leading_zero $month
month=$?

day_index $day $month $year
date2=$?

abs $date2				# Make sure its positive.
date2=$value

calculate_difference $date1 $date2

abs $diff				# Make sure its positive.
diff=$value

echo $diff

exit 0













