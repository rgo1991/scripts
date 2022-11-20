#!/bin/bash
###########
# Passing an array to a function and returning an array from a function
###########


Pass_array(){


local passed_array
passed_array= ( `echo "$1"` )
echo "${passed_array[@]}"

# List all the elements of the new array declared and set withing the function

}

original_array=( element1 element2 element3 element4 element5 )
echo
echo "original_array = ${original_array[@]}" # list all the elements of the original array

#This is the trick that permits passing an array to a function
#
argument=`echo ${original_array[@]}`
#
# Pack a variable will all the space-separated elements of the original array
# Note that attempting to just pass the array itself will not work

# This is the trick that allows grabbing an array as a "return value"
#
returned_array=( `Pass_array "$argument"` )
#
# Assign echoed output of function to array variable.

echo "returned array = ${returned_array[@]}"

echo =======================================

# Now try it again attempting to access (list) the arrray from outside the function

Pass_array "$argument"

# The function itself lists the array, but accessing the array from outside the function is forbidden
#
echo "Passed array (within function) = ${passed_array[@]}"
#
# Gives null value since this is a variable local to the function

exit 0


