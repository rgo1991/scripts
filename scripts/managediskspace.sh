#!/bin/bash

FILES=( $(find . -maxdepth 1 -type f -size +10000c) )
NUM_FILES=`find . -maxdepth 1 -type f -size +10000c | wc -l`
LOGFILE=diskusagelog.log




diskspace(){

        echo "Press \"t\" to touch `basename $i` or press \"c\" to copy `basename $i`"
        read task -p 2&>1
                case $task in
                        c|C)    echo "Copying `basename $i` into /tmp/"
                                cp $i /tmp/
                                echo "Copied `basename $i` into /tmp/ on `date`" >> $LOGFILE ;;
                        t|T)    echo "Touching `basename $i`"
                                touch $i
                                echo "Touched `basename $i` on `date`" >> $LOGFILE ;;
                        *)      echo "I Don't recognise the answer"
                                diskspace;;

                esac


}





echo "Found $NUM_FILES files over 10000 bytes"

for i in ${FILES[@]};do
diskspace
done
