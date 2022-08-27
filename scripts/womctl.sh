#!/bin/sh
#
# Script to control Wombat processes
######################################
#
# Version 1.3
#
# Updated to handle using 'cset'
#
# proc.conf can have -
# <program>@1,3 for taskset
# or
# <program>@cset_<setname> for cset
#
######################################
#
# Version 1.4
#
# Updated to handle v5 feeds
#
# The script will source profile.wombat_v5
# if starting v5 processes
#
######################################
#
# Version 1.4.1
#
# Updated to set EVENT_VMS_POLL_OVERRIDE
# when starting some CTAs on njwammcp24,25,a,b
#
# SFD-886
#
######################################
#
# Version 1.5
#
# Updated to correct monitoring permission
# errors in papastats .csv files
#
# SFD-1040
#
######################################
#
# Version 1.6
#
# Added section to source VMS1.3.8.2 libraries for v5 mamacache
#
#
######################################

export WMW_IBV_SW_CKSUM=1
ALLOWED_USER="vela"
LOG=$WOMBAT_LOGS/womctl.log
NSD_CONF=$SCRIPTS_HOME/config/nsd.conf
PROC_CONF=$SCRIPTS_HOME/config/proc.conf
HOST=`hostname -s`

# allow  double the default open files
ulimit -n 2048

if [ "$USER" != "$ALLOWED_USER" ]
then
   echo "[`basename $0`] This script may only be executed by the user [$ALLOWED_USER] not [$USER]"
   exit 1
fi

printwho()
{
    who am i | awk '{print "["$1"|"$2"|"$3"-"$4" "$5"|"$6"]"}' | sed 's/[(,)]//g'
}

printtime()
{
    date +"%Y-%m-%d %T"
}

usage()
{
    echo "[`basename $0`] Usage: /etc/init.d/womctl start <proc>" >&2
    echo "[`basename $0`]   or:  /etc/init.d/womctl stop  <proc> [<proc> ...]" >&2
}

# Function to check for a taskset setting or a cpuset setting
#
parse_taskset() {
   program=`echo $1 | awk -F'@' '{print $1}'`
   taskset_str=""
   cpuset_str=`echo $1 | awk -F'@' '{print $2}'`
}

# Function to check if starting a V5 process
#
check_v5() {
   echo $1 | awk -F'_' '{print $2}'
}
check_v5_cache() {
   echo $1 | awk -F'_' '{print $1"_"$2}'
}

check_sb() {
   echo $1 | awk -F'_' '{print $1}'
}

pidlist()
{
    if [ x`uname -s` = xSunOS ]
    then
        ps -ef -o "pid comm" | sed 's/[^/ ]*\///g' | grep -w $1 | sed -e 's/^  *//' -e 's/ .*//'
    else
        ps -eF | grep -w ${1} | grep -v "grep" | grep -v "womctl" |awk '{print $2}' | sed -e 's/^  *//' -e 's/ .*//'
    fi
}

# Function to kill the named process(es)
#
killproc() {
        pid=`pidlist $1`
        [ "$pid" != "" ] && kill $pid
        if [ "$pid" != "" ]
        then
           echo "[`basename $0`] `printtime`:`printwho`: killing [$1] with PID [$pid]" >> $LOG
        else
           echo "[`basename $0`] `printtime`:`printwho`: [$1] not running" >> $LOG
        fi
}

echo "[`basename $0`] `printtime`:`printwho`: Command: [womctl $*]" >> $LOG

start() {

   parse_taskset $2

   is_v5=`check_v5 $2`
   is_v5_cache=`check_v5_cache $2`
   is_sb=`check_sb $2`

   pid=`pidlist $program`

   if [ "$pid" != "" ] && [ "$2" != "all" ]
   then
       echo "[`basename $0`] ${program}: already running" >&2
       echo "[`basename $0`] `printtime`:`printwho`: [$program] already running" >> $LOG
       return 1
   fi

   if [ -n "$WOMBAT_LOGS" -a -d "$WOMBAT_LOGS" ];
   then
       cd $WOMBAT_LOGS
   fi

   case "$2" in
    'siteserver'*)
        program="siteserver.sh"
        site="`echo "${2}" | awk -F'_' '{print $2}'`"
        shift 2
        args="$*"

        if [ "`echo $args | sed 's/ //g'`" == "" ]
        then
                args="-start -config_dir $ENTS_HOME/config/sites/$site -install_dir $ENTS_HOME"
        fi
        echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args]" >> $LOG
        echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args]" >> $WOMBAT_LOGS/$program.stderr.log
        $program $args >> $WOMBAT_LOGS/$program.stderr.log 2>&1 &
        ;;

    'nagios'*)
        program=$2
        shift 2
        args="$*"

        if [ "`echo $args | sed 's/ //g'`" == "" ]
        then

                args="-d $NAGIOS_HOME/config/nagios.cfg"
        fi

        echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args]" >> $LOG
        echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args]" >> $WOMBAT_LOGS/$program.stderr.log
        $program $args >> $WOMBAT_LOGS/$program.stderr.log 2>&1 &
        ;;

    'nrpe')
        program=$2
        shift 2
        args="$*"

        if [ "`echo $args | sed 's/ //g'`" == "" ]
        then

                #args="-d -c $NRPE_HOME/config/nrpe.cfg"
                /opt/vela/nrpe/bin/nrpe -d -c /opt/vela/nrpe/config/nrpe.cfg

        fi

        echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args]" >> $LOG
        echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args]" >> $WOMBAT_LOGS/$program.stderr.log
        $program $args >> $WOMBAT_LOGS/$program.stderr.log 2>&1 &
        ;;

    'nsd'*)

        shift 2
        args="$*"

        if [ "`echo $args | sed 's/ //g'`" == "" ]
        then

                if [ -f $NSD_CONF ]
                then
                        IP="`grep $HOST $NSD_CONF | grep -v "^#" | awk -F':' '{print $2}'`"
                        PORT="`grep $HOST -s $NSD_CONF | grep -v "^#" | awk -F':' '{print $3}'`"
                        WEB="`grep $HOST -s $NSD_CONF | grep -v "^#" | awk -F':' '{print $4}'`"
                        args="-i $IP -p $PORT -w $WEB"
                else
                        echo "[`basename $0`] No NSD arguments or config [$NSD_CONF]"
                        exit 1
                fi

        fi

        if [ "$is_v5" == "v5" -o "$is_sb" == "superbook" ]
        then
             . /opt/vela/scripts/profile.wombat_v5
             program="nsd"
        fi

        if [ "$taskset_str" == "" ]
        then
                echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args]" >> $LOG
                echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args]" >> $WOMBAT_LOGS/$program.stderr.log
                $program $args >> $WOMBAT_LOGS/$program.stderr.log 2>&1 &
        elif [ "$cpuset_str" == "" ]
        then
                echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args] with taskset: [$taskset_str]" >> $LOG
                echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args] with taskset: [$taskset_str]" >> $WOMBAT_LOGS/$program.stderr.log
                taskset -c $taskset_str $program $args >> $WOMBAT_LOGS/$program.stderr.log 2>&1 &
        else
                echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args] with cset: [$cpuset_str]" >> $LOG
                echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args] with cset: [$cpuset_str]" >> $WOMBAT_LOGS/$program.stderr.log
                umask 023
                cset proc -e $cpuset_str -- $program $args >> $WOMBAT_LOGS/$program.stderr.log 2>&1 &
        fi

        if [ "$is_v5" == "v5" -o "$is_sb" == "superbook" ]
        then
             . /opt/vela/scripts/profile.wombat
        fi
        ;;
    'smdsadapter'*)

        . /opt/vela/scripts/profile.smds
        echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args] with cset: [$cpuset_str]" >> $LOG
        echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args] with cset: [$cpuset_str]" >> $WOMBAT_LOGS/$program.stderr.log
        umask 023
        cset proc -e $cpuset_str -- $program $args >> $WOMBAT_LOGS/$program.stderr.log 2>&1 &
        #$program $args >> $WOMBAT_LOGS/$program.stderr.log 2>&1 &
    ;;
      # SMART Stuff
       mamacache_nyseoism_prod*|mamadict_templates*|mamacache_iextops_prod*)
           shift 2
           args="$*"
          . /opt/vela/scripts/profile.smart

          echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args] with cset: [$cpuset_str]" >> $WOMBAT_LOGS/$program.stderr.log
          umask 023
          cset proc -e $cpuset_str -- $program $args >> $WOMBAT_LOGS/$program.stderr.log 2>&1 &

      ;;
    'dbac'*)
        . /opt/vela/scripts/profile.dbac
        echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args] with cset: [$cpuset_str]" >> $LOG
        echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args] with cset: [$cpuset_str]" >> $WOMBAT_LOGS/$program.stderr.log
        umask 023
        $program $args >> $WOMBAT_LOGS/$program.stderr.log 2>&1 &
    ;;

    'all')

        PROCS=`grep $HOST $PROC_CONF | grep -v "^#" | awk -F':' '{print $2}'`

        OLD_IFS="${IFS}"
        IFS="|"

        for PROC in $PROCS
        do
                echo "[`basename $0`] Starting [$PROC]"
                IFS="${OLD_IFS}"
                start "start" $PROC
                sleep 3
                IFS="|"
        done

        IFS="${OLD_IFS}"

        ;;

    *)

        shift 2
        args="$*"

#        if [ "$is_v5" == "v5" -o "$is_sb" == "superbook" ] && [ "$is_v5_cache" != "mamacache_v5" ]
#        then
#             . /opt/vela/scripts/profile.wombat_v5
#        elif [ "$is_v5_cache" == "mamacache_v5" ]
#        then
#             . /opt/vela/scripts/profile.wombat_v5_mamacache
#        fi
        if [ "$cpuset_str" == "" ]
        then
                echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args]" >> $LOG
                echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args]" >> $WOMBAT_LOGS/$program.stderr.log
                $program $args >> $WOMBAT_LOGS/$program.stderr.log 2>&1 &
        else
                echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args] with cset: [$cpuset_str]" >> $LOG
                echo "[`basename $0`] `printtime`:`printwho`: starting [$program] with args: [$args] with cset: [$cpuset_str]" >> $WOMBAT_LOGS/$program.stderr.log
                umask 023
                cset proc -e $cpuset_str -- $program $args >> $WOMBAT_LOGS/$program.stderr.log 2>&1 &
        fi

        if [ "$is_v5" == "v5" -o "$is_sb" == "superbook" ]
        then
             . /opt/vela/scripts/profile.wombat
        fi

        ;;
    esac

}

stop () {

        case "$2" in
         'all')
                PROCS=`grep $HOST $PROC_CONF | grep -v "^#" | awk -F':' '{print $2}'`

                OLD_IFS="${IFS}"
                IFS="|"

                for PROC in $PROCS
                do
                        parse_taskset $PROC
                        echo "[`basename $0`] Stopping [$program]"
                        IFS="${OLD_IFS}"
                        stop "stop" $program
                        sleep 1
                        IFS="|"
                done

                IFS="${OLD_IFS}"
                ;;

         'siteserver'*)
                program="siteserver.sh"
                site="`echo "${2}" | awk -F'_' '{print $2}'`"
                shift 2
                args="$*"

                if [ "`echo $args | sed 's/ //g'`" == "" ]
                then
                        args="-stop -config_dir $ENTS_HOME/config/sites/$site -install_dir $ENTS_HOME"
                fi
                echo "[`basename $0`] `printtime`:`printwho`: stopping [$program] with args: [$args]" >> $LOG
                echo "[`basename $0`] `printtime`:`printwho`: stopping [$program] with args: [$args]" >> $WOMBAT_LOGS/$program.stderr.log
                $program $args >> $WOMBAT_LOGS/$program.stderr.log 2>&1 &
                ;;

         *)
                [ -z "$2" ] && usage
                while [ -n "$2" ]
                do
                        if [ "$2" == "nsd_v5" ]
                        then
                            killproc "nsd"
                        else
                            killproc $2
                        fi
                        shift
                done
                ;;
        esac
}

case "$1" in
'start')
        start $*
    ;;

'stop')
        stop $*
    ;;

'restart')

        stop $*
        sleep 5
        start $*
    ;;

*)
    usage
    ;;
esac

echo "[`basename $0`] `printtime`:`printwho`: exiting womctl" >> $LOG
