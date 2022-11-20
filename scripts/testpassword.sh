#!/bin/bash

PASSWORD=$1
[ ${#PASSWORD} -lt "8" ] && echo "Password too short. It must be at least 8 characters"




declare -a array

# Make each letter in the provided password an element in the array. 
for i in `seq 0 $((${#PASSWORD} - 1))`;do
array[${#array[@]}]=${1:$i:1};done

# Grep a set of 4 characters in dictionary.txt. Then move over 1 with each iteration of loop.
for i in `seq 0 $((${#PASSWORD} - 4))`;do
grep -q ${PASSWORD:$i:4} dictionary.txt
[ $? -eq "0" ] && echo "Your password contains words that are easy to guess pick a new password" && exit 1;done


NUM_COUNT=0
CHAR_COUNT=0

# Check if an array element is a digit or a special char and increase count if it is. 
for p in ${array[@]};do
	[[ "$p" =~ [[:digit:]] ]] && let NUM_COUNT=$NUM_COUNT+1 
	[[ "$p" != [A-Za-z0-9] ]] && let CHAR_COUNT=$CHAR_COUNT+1
done

[ $NUM_COUNT -lt "1" ] || [ $CHAR_COUNT -lt "1" ] && echo "Password must contain at least one numeric AND one special character"
[ $NUM_COUNT -ge "1" ] && [ $CHAR_COUNT -ge "1" ] && echo "Password created"



