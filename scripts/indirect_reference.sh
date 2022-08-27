#!/bin/bash

a=letter_of_the_alphabet
letter_of_the_alphabet=z

# Direct reference
echo a = $a 		# a = letter_of_the_alphabet
echo

# Indirect reference
eval a=\$$a
echo "Now a is = $a"

### ABS page 457

#-----------------
# Sourcing stuff from a seprate file and using indirect referencing.
my_remote_net=172.16.0.100
your_remote_net=10.0.0.10
isonline="my"

remote_net=$(eval "echo \$$(echo ${isonline}_remote_net)")
remote_net=$(eval "echo \$$(echo my_remote_net)")



