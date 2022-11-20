#!/bin/bash


SURVIVE=2
BIRTH=3


startfile=gen0		# Read the starting generation from the file gen0
			# Default, if no other file specified when invoking the script
			
if [ -n $1 ];then		# Specify another generation 0 file
	if [ -e "$1" ];then	# Check for existence
		startfile="$1"
	fi
fi


ALIVE1=.		# Represent living and dead cells in the start-up file
DEAD1=_


# This script uses a 10 x 10 grid which can be increased, but will caused slower execution.

ROWS=10
COLS=10

GENERATIONS=10		# How many generations to cycle through

NONE_ALIVE=80		# Exit status if no cells left alive

TRUE=0
FALSE=1
ALIVE=0
DEAD=1


avar=			# Global: holds current generation
generation=0		# Initialize generation count.


#==========================================================


let "cells = $ROWS * $COLS"


declare -a initial	# Arrays containing cells
declare -a current

display(){


alive=0			# How many cells alive. Initially zero

declare -a arr
arr=( `echo "$1"` )	# Convert passed argument to array.


element_count=${arr[*]}

local i
local rowcheck

for ((i=0; i<$element_count; i++));do

	let "rowcheck = $i % ROWS"	# Insert newline at end of each row
	if [ "$rowcheck" -eq 0 ];then
		echo			# New line
		echo -n "	";fi	# Indent

	cell=${arr[i]}

	if [ "$cell" = . ];then
		let "alive += 1";fi


	echo -n $cell | sed -e 's/_/ /g'	# Print out array and checge underscores to spaces.

done

}




isvalid(){

if [ -z "$1" -o -z "$2" ];then		# Mandatory arguments missing.
	return $FALSE;fi

local row			
local lower_limit=0		# Dissallow negative coordinates
local upper_limit
local left
local right

let "upper_limit = $ROWS * $COLS - 1"	# Total number of cells

if [ "$1" -lt "$lower_limit" -o "$1" -gt "$upper_limit" ];then
	return $FALSE;fi		# Out of array bounds

row=$2
let "left = $row * $ROWS"		# Left limit
let "right = $left + $COLS - 1"		# Right limit

if [ "$1" -lt "$left" -o "$1" -gt "$right" ];then
	return $FALSE;fi		# Beyond row boundary

return $TRUE

}


isalive(){			# Test whether the cell is alive.
				# Takes array, cell number, state of cell as arguments.

GetCount "$1" $2		# Get alive cell count in neighbourhood
local nhbd=$?

if [ $nhbd -eq $BIRTH ];then
	return $ALIVE;fi

if [ "$3" = "." -a "$nhbd" -eq "$SURVIVE" ];then
	return $ALIVE;fi

return $DEAD			# Default


}



GetCount(){			# Count live cells in passed cell's neighbourhood
				# Two arguments needed: $1 variable holding array. $2 cell number

local cell_number=$2
local array
local top
local center
local bottom
local r
local row
local i
local t_top
local t_cen
local t_bot
local count=0
local ROW_NHBD=3


array=( `echo "$1"` )

let "top = $cell_number - $COLS - 1"	# Set up cell neighbourhood
let "center = $cell_number - 1"		#
let "bottom = $cell_number + $COLS - 1" #
let "r = $cell_number / $ROWS"		#


for ((i=0; i<$ROW_NHDB; i++));do	# Traverse from left to right
	let "t_top = $top + $i"
	let "t_cen = $center + $i"
	let "t_bot = $bottom + $i"

	let "row = $r"				# Count center row of neighbourhood
	isvalid $t_cen $row			# Valid cell position?
	if [ $? -eq "$TRUE" ];then
		if [ ${array[$t_cen]} == "$ALIVE" ];then	# Is it alive
			let "count += 1"			# Yes?
		fi						# Increment count
	fi


	let "row = $r - 1"			# Count top row.
	isvalid $t_top $row
	if [ $? -eq "$TRUE" ];then
		if [ ${array[$t_top]} == "$ALIVE1"];then	
			let "count += 1"
		fi
	fi


	let "row = $r - 1"			# Count bot row
	isvalid $t_bot $row	
	if [ $? -eq "$TRUE" ];then
		if [ ${array[$t_bot]} == "$ALIVE1"];then
			let "count += 1"
		fi
	fi
done


if [ ${array[$cell_number]} == "$ALIVE" ];then	# Make sure value of tested cell itself is not counted.
	let "count -= 1";fi

return $count

}



















