cript to roll logs on a nightly basis
#

. /opt/vela/scripts/profile.wombat

DATE=`date +%Y%m%d`
CACHEDATE=`date +"%Y-%m-%d"`
YESTERDAY=`date -d yesterday +%Y%m%d`
YEST_SITESERVER=`date -d yesterday +"%Y-%m-%d"`
WEEKLYDATE=`date -d "1 week ago" +%Y%m%d`
MONTHLYDATE=`date -d "1 month ago" +%Y%m%d`

LOG=$WOMBAT_LOGS/wlogroll.log
PROC_CONF=$WOMBAT_HOME/scripts/config/proc.conf
HOST=`hostname -s`
ARCHIVE=$WOMBAT_LOGS/archive/$DATE/

printwho()
{
    who am i | awk '{print "["$1"|"$2"|"$3"-"$4" "$5"|"$6"]"}' | sed 's/[(,)]//g'
}

printtime()
{
    date +"%Y-%m-%d %T"
}

mkdir -p $ARCHIVE >> $LOG 2>&1

PROCS=`grep $HOST $PROC_CONF | grep -v "^#" | awk -F':' '{print $2}'`

OLD_IFS="${IFS}"
IFS="|"

for PROC in $PROCS
do
        IFS="${OLD_IFS}"

        #check for possible taskset in proc.conf - denoted with '@'
        process=`echo $PROC | awk -F'@' '{print $1}'`

        case $process in
                "nsd")
                        # No special handling
                ;;

                "siteserver"*)
                        # No special handling
                ;;

                "nrpe")
                        # No special handling
                ;;

                "mamacache"*|"super"*|"mcache"*)

                        # Roll 2.99 logs - needs special handling

                        echo "[`basename $0`] `printtime`:`printwho`: wadmin $process.$HOST rollLogFiles " >> $LOG 2>&1
                        wadmin $process.$HOST rollLogFiles >> $LOG 2>&1
                        sleep 2
                        # force a log write
                        wadmin $process.$HOST status >> $LOG 2>&1

                        echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/$process.log_${CACHEDATE}* to $ARCHIVE/$process.$HOST.$DATE.log " >> $LOG 2>&1
                        # move to archive
                        mv $WOMBAT_LOGS/$process.log_${CACHEDATE}* $ARCHIVE/ >> $LOG 2>&1

                        LOGS="1 2 3 4 5 6 7 8 9"
                        for i in $LOGS
                        do
                                if [ -e "$WOMBAT_LOGS/$process.log$i" ]
                                then
                                        echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/$process.log$i to $ARCHIVE/$process.$HOST.$DATE.log$i " >> $LOG 2>&1
                                        mv $WOMBAT_LOGS/$process.log$i $ARCHIVE/$process.$HOST.$DATE.log$i >> $LOG 2>&1
                                fi
                        done

                        #There's a bug in mamacache rollPapastats, so skipping it.  The papastats files will be picked up in the next step

                        # need to handle old papastats files and 'transport_' papastats files. archive any papastats files (up to 9) with yesterday's date.
                        for i in $LOGS
                        do
                                if [ -e "$WOMBAT_LOGS/$process${YESTERDAY}_$i.csv" -o -e "$WOMBAT_LOGS/transport_$process${YESTERDAY}_$i.csv" ]
                                then
                                        echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/*$process${YESTERDAY}_$i.csv to $ARCHIVE/$process.$HOST.${YESTERDAY}_$i.csv " >> $LOG 2>&1
                                        mv $WOMBAT_LOGS/*$process${YESTERDAY}_$i.csv $ARCHIVE >> $LOG 2>&1
                                fi
                        done
                ;;

                *)

                        # Roll feed handler logs
                        echo "[`basename $0`] `printtime`:`printwho`: wadmin $process.$HOST rolloverLog $process.$HOST.$DATE.log" >> $LOG 2>&1
                        wadmin $process.$HOST rolloverLog $process.$HOST.$DATE.log >> $LOG 2>&1
                        sleep 2
                        # force a log write
                        wadmin $process.$HOST status >> $LOG 2>&1

                        echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/$process.$HOST.$DATE.log* to $ARCHIVE " >> $LOG 2>&1
                        # move to archive
                        mv $WOMBAT_LOGS/$process.$HOST.$DATE.log* $ARCHIVE >> $LOG 2>&1

                        LOGS="1 2 3 4 5 6 7 8 9"
                        for i in $LOGS
                        do
                                if [ -e "$WOMBAT_LOGS/$process.log$i" ]
                                then
                                        echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/$process.log$i to $ARCHIVE/$process.$HOST.$DATE.log$i " >> $LOG 2>&1
                                        mv $WOMBAT_LOGS/$process.log$i $ARCHIVE/$process.$HOST.$DATE.log$i >> $LOG 2>&1
                                fi
                        done

                        # papastats
                        echo "[`basename $0`] `printtime`:`printwho`: wadmin $process.$HOST rolloverPapastats $process.$HOST.$DATE.csv " >> $LOG 2>&1
                        wadmin $process.$HOST rolloverPapastats $process.$HOST.$DATE.csv >> $LOG 2>&1
                        sleep 10 # papastats interval
                        echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/$process.$HOST.$DATE.csv to $ARCHIVE " >> $LOG 2>&1
                        # move to archive
                        mv $WOMBAT_LOGS/$process.$HOST.$DATE.csv $ARCHIVE >> $LOG 2>&1

                        # need to handle old papastats files. archive any papastats files (up to 9) with yesterday's date.
                        for i in $LOGS
                        do
                                if [ -e "$WOMBAT_LOGS/$process${YESTERDAY}_$i.csv" ]
                                then
                                        echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/$process${YESTERDAY}_$i.csv to $ARCHIVE/$process.$HOST.${YESTERDAY}_$i.csv " >> $LOG 2>&1
                                        mv $WOMBAT_LOGS/$process${YESTERDAY}_$i.csv $ARCHIVE/$process.$HOST.${YESTERDAY}_$i.csv >> $LOG 2>&1
                                fi
                        done

                        # symbolfile
                        echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/$process.sym to $ARCHIVE/$process_${HOST}.${DATE}.sym " >> $LOG 2>&1
                        cp $WOMBAT_LOGS/$process.sym $ARCHIVE/${process}_${HOST}.${DATE}.sym >> $LOG 2>&1
                ;;
        esac

        #move stderr log
        echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/$process.stderr.log to $ARCHIVE/$process.$HOST.$DATE.stderr.log " >> $LOG 2>&1
        mv $WOMBAT_LOGS/$process.stderr.log $ARCHIVE/$process.$HOST.$DATE.stderr.log >> $LOG 2>&1
        # create new stderr log indicating it has been rolled
        echo "[`basename $0`] `printtime`:`printwho`: Log file rolled">> $WOMBAT_LOGS/$process.stderr.log 2>&1

        IFS="|"
done

IFS="${OLD_IFS}"

# move womctl log
echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/womctl.log to $ARCHIVE/womctl.$HOST.$DATE.log " >> $LOG 2>&1
mv $WOMBAT_LOGS/womctl.log $ARCHIVE/womctl.$HOST.$DATE.log >> $LOG 2>&1
# create new womctl log indicating it has been rolled
echo "[`basename $0`] `printtime`:`printwho`: Log file rolled">> $WOMBAT_LOGS/womctl.log 2>&1

# move wsync log
echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/wsync.log to $ARCHIVE/wsync.$HOST.$DATE.log " >> $LOG 2>&1
mv $WOMBAT_LOGS/wsync.log $ARCHIVE/wsync.$HOST.$DATE.log >> $LOG 2>&1
# create new wsync log indicating it has been rolled
echo "[`basename $0`] `printtime`:`printwho`: Log file rolled">> $WOMBAT_LOGS/wsync.log 2>&1

# move cron log
echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/cron.log to $ARCHIVE/cron.$HOST.$DATE.log " >> $LOG 2>&1
mv $WOMBAT_LOGS/cron.log $ARCHIVE/cron.$HOST.$DATE.log >> $LOG 2>&1
# create new cron log indicating it has been rolled
echo "[`basename $0`] `printtime`:`printwho`: Log file rolled">> $WOMBAT_LOGS/cron.log 2>&1

# move old siteserver logs
echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/siteserver$YEST_SITESERVER* to $ARCHIVE/" >> $LOG 2>&1
mv $WOMBAT_LOGS/siteserver$YEST_SITESERVER* $ARCHIVE/>> $LOG 2>&1

# move any sym file backups
echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/*$DATE*sym to $ARCHIVE/" >> $LOG 2>&1
mv $WOMBAT_LOGS/*$DATE*sym $ARCHIVE/>> $LOG 2>&1
echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/*sym.$DATE* to $ARCHIVE/" >> $LOG 2>&1
mv $WOMBAT_LOGS/*sym.$DATE* $ARCHIVE/>> $LOG 2>&1

# move wsavesymfile log
echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/wsavesymfile.log to $ARCHIVE/" >> $LOG 2>&1
mv $WOMBAT_LOGS/wsavesymfile.log $ARCHIVE/>> $LOG 2>&1

# move perf output
echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/*perf*.$DATE.csv to $ARCHIVE/" >> $LOG 2>&1
mv $WOMBAT_LOGS/*perf*.$DATE.csv $ARCHIVE/>> $LOG 2>&1

# move wlogroll log
echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/wlogroll.log to $ARCHIVE/wlogroll.$HOST.$DATE.log " >> $LOG 2>&1
mv $WOMBAT_LOGS/wlogroll.log $ARCHIVE/wlogroll.$HOST.$DATE.log >> /dev/null 2>&1

# move opraMaxRate log
echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/opraMaxRate.conf to $ARCHIVE/opraMaxRate.conf.$HOST.$DATE.log " >> $LOG 2>&1
cp $WOMBAT_LOGS/archive/opraMaxRate.conf $ARCHIVE/opraMaxRate.conf.$HOST.$DATE.log >> /dev/null 2>&1

# move opraMaxKB log
echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/opraMaxKB.conf to $ARCHIVE/opraMaxKB.conf.$HOST.$DATE.log " >> $LOG 2>&1
cp $WOMBAT_LOGS/archive/opraMaxKB.conf $ARCHIVE/opraMaxKB.conf.$HOST.$DATE.log >> /dev/null 2>&1

# move equitiesMaxRate log
echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/equitiesMaxRate.conf to $ARCHIVE/equitiesMaxRate.conf.$HOST.$DATE.log " >> $LOG 2>&1
cp $WOMBAT_LOGS/archive/equitiesMaxRate.conf $ARCHIVE/equitiesMaxRate.conf.$HOST.$DATE.log >> /dev/null 2>&1

# move equitiesMaxKB log
echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/opraMaxKB.conf to $ARCHIVE/opraMaxKB.conf.$HOST.$DATE.log " >> $LOG 2>&1
cp $WOMBAT_LOGS/archive/equitiesMaxKB.conf $ARCHIVE/equitiesMaxKB.conf.$HOST.$DATE.log >> /dev/null 2>&1

# move streamingMaxRate log
echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/streamingMaxRate.conf to $ARCHIVE/streamingMaxRate.conf.$HOST.$DATE.log " >> $LOG 2>&1
cp $WOMBAT_LOGS/archive/streamingMaxRate.conf $ARCHIVE/streamingMaxRate.conf.$HOST.$DATE.log >> /dev/null 2>&1

# move streamingMaxKB log
echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/streamingMaxKB.conf to $ARCHIVE/streamingMaxKB.conf.$HOST.$DATE.log " >> $LOG 2>&1
cp $WOMBAT_LOGS/archive/streamingMaxKB.conf $ARCHIVE/streamingMaxKB.conf.$HOST.$DATE.log >> /dev/null 2>&1

# move futuresMaxRate log
echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/futuresMaxRate.conf to $ARCHIVE/futuresMaxRate.conf.$HOST.$DATE.log " >> $LOG 2>&1
cp $WOMBAT_LOGS/archive/futuresMaxRate.conf $ARCHIVE/futuresMaxRate.conf.$HOST.$DATE.log >> /dev/null 2>&1

# move futuresMaxKB log
echo "[`basename $0`] `printtime`:`printwho`: moving $WOMBAT_LOGS/futuresMaxKB.conf to $ARCHIVE/futuresMaxKB.conf.$HOST.$DATE.log " >> $LOG 2>&1
cp $WOMBAT_LOGS/archive/futuresMaxKB.conf $ARCHIVE/futuresMaxKB.conf.$HOST.$DATE.log >> /dev/null 2>&1

# tar up logs
echo "[`basename $0`] `printtime`:`printwho`: tarring $WOMBAT_LOGS/archive/$DATE" >> $LOG 2>&1
cd $WOMBAT_LOGS/archive/
tar -cjf $DATE.tar.bz2 $DATE >> $LOG 2>&1
#bzip2 $DATE.tar >> $LOG 2>&1

# remove old unused archive build directories (keeps archives) after 1 week
echo "[`basename $0`] `printtime`:`printwho`: removing $WOMBAT_LOGS/archive/$YESTERDAY" >> $LOG 2>&1
rm -rf $WOMBAT_LOGS/archive/$YESTERDAY  $WOMBAT_LOGS/archive/$WEEKLYDATE >> $LOG 2>&1

# clear temp nagios files
rm $WOMBAT_LOGS/nagios/* >> /dev/null 2>&1

