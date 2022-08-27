#!/bin/bash

quarter=25
dime=10
nickle=5
cent=1


sum=( $(echo $1|sed 's/\$//g;s/\.//g') )
echo $sum


func_remainder(){

remainder=$(("$1" % "$2"))
}



func_num(){
num=$(("$1" / "$2"))
}

	func_num $sum $quarter
	func_remainder $sum $quarter
	echo -n best change for $1 is $num-quarter\(s\), 
		if [ $remainder > 10 ];then
		func_num $remainder $dime
		func_remainder $remainder $dime
	        echo -n $num-dime\(s\), 
			if [ $remainder > 5 ];then
				func_num $remainder $nickle
				func_remainder $remainder $nickle
				       	echo -n $num-nickel\(s\), 
					if [ $remainder > 0 ];then
						func_num $remainder $cent
						func_remainder $remainder $cent
						echo and $num-cents.;fi;fi;fi
