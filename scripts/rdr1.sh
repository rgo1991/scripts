#!/bin/bash
# Redirecting stdin using 'exec'.
#exec 6<&0 # Link file descriptor #6 with stdin.
 # Saves stdin.
exec 6<> data-file # stdin replaced by file "data-file"
while read line <&6;do
 # Reads first line of file "data-file".
 # Reads second line of file "data-file."
echo
echo "Following lines read from file."
echo "-------------------------------"
echo $line
echo 
done
echo; echo; echo
exec 6<&- 6>&-
# Now restore stdin from fd #6, where it had been saved,
#+ and close fd #6 ( 6<&- ) to free it for other processes to use.
#
# <&6 6<&- also works.
echo -n "Enter data "
read b1 # Now "read" functions as expected, reading from normal stdin.
echo "Input read from stdin."
echo "----------------------"
echo "b1 = $b1"
echo
exit 0
#Similarly, an ex
