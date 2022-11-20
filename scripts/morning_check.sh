#!/bin/bash

#!/bin/bash
############################################################################################
# Roberto Omana
# NYFIX, Inc.
# 7:21 PM Friday, August 17, 2012
# 3:16 PM Tuesday, July 30, 2013
############################################################################################
# Name          : runUSMorningChecks.sh
# LogFile       : /tmp/runUSMorningChecks.log
# Requirement   : $1 = environment as defined under 'morning check sources'
# Output        : copy of check output in $local_archive_path/$mybackupfolder/
#               : -- uses the source as prefix and `date +%Y%m%d%H%M%S` as suffix to avoid accidental overwriting
#
# History :
# --------
# Initials   Date           Description
# --------   ----------     ------------
# romana     08/17/2012     initial version
# romana     04/24/2013     bugfix; typo errors
# romana     05/06/2013     updated scripts. now using actual server sources.
# romana     05/08/2013     updated subject headers + archive folders + utpxdp script; added archive maintenance
# romana     05/09/2013     bugfix; adjusted staging to run in pm1sfdmn01v instead
# romana     05/15/2013     added remote archiving + maintenance
# romana     07/30/2013     bugfix; prevent script from ssh to pm1sfdmn01v
# adionisio  07/25/2014     changed archiving and path for migration to pm3sfdmn01; added allowance to run in bkup repo
############################################################################################
# This script consolidated the morning checks for any box accesible to pm3sfdmn01 or pm3sfdmn02
# TBD: 1. where to backup historical checks
############################################################################################
# immediately save the parameter used
param1=$1

# email recepients
#BRECIPIENTS="r.omana@srtechlabs.com"
BRECIPIENTS="romana@velatt.com"
#BRECIPIENTS="acruz@velatt.com"
#TRECIPIENTS="acruz@velatt.com"
#TRECIPIENTS="r.omana@srtechlabs.com"
#TRECIPIENTS="managedservices@srtechlabs.com"
TRECIPIENTS="managedservices@velatradingtech.com"

# constants
#temp_path="/tmp"
temp_path="/opt/wombat/global_scripts/log"
local_archive_path="/opt/wombat/us" # change archive path here
logfile="$temp_path/runUSMorningChecks.log"
myhost=`hostname -s`
ARCHIVE_HOST=10.188.64.159 # <--- this is the IP of pm2sfdmn01v


# variables
rundate=`date`
runtime=`date +%I%M%p`
myYearMonthDay=`date +%Y%m%d`
myYearMonthDayHourMinSec=` date +%Y%m%d%H%M%S`
mc_servers="ny2_prod cermak mahwah ny2_staging weehaken utpxdp xdp xdpftp"

#############################################################################
# to add more checks
# 1. add a unique source in mc_servers list
# 2. add the source and script name
#    format: <server>|<executable script] - note that server should be accesible to pm3sfdmn01
# 3. add backup destination - which should be under $local_archive_path
# 4. add a mail header
#############################################################################

##### morning check sources | archive server | script names
ny2_prod_script="pny2mamgt01v||/opt/wombat/us/ny2/production/scripts/bin/morning_checks/earlyMorningChecksSuperFeed.sh"

# old script - staging="njwamstc08|/opt/wombat/scripts/bin/morning_checks/morningChecksSuperFeed.sh"
#staging_script="pm3sfdmn01|pm3sfdmn02|/opt/wombat/us/weehaken/staging/scripts/bin/morning_checks/morningChecksSuperFeed.sh"
ny2_staging_script="pny2mamgt01v||/opt/wombat/us/ny2/staging/scripts/bin/morning_checks/morningChecksSuperFeed.sh"

# old script weehaken="njwammcp04b|/opt/wombat/scripts/bin/morning_checks/morningChecksSuperFeed.sh"
#weehaken_script="njwammcp27a|/opt/wombat/scripts/bin/morning_checks/morningChecksSuperFeed.sh"
weehaken_script="pm3sfdmn01|pm3sfdmn02|/opt/wombat/us/weehaken/production/scripts/bin/morning_checks/morningChecksSuperFeed.sh"

# old script- cermak="pckmcwom04b|/opt/wombat/scripts/bin/morning_checks/morningChecksSuperFeed.sh"
cermak_script="pny2mamgt01v||/opt/wombat/us/cermak/production/scripts/bin/morning_checks/morningChecksSuperFeed.sh"

# old script - mahwah="pm3sfdut01b|/opt/wombat/scripts/bin/morning_checks/morningChecksSuperFeed.sh"
mahwah_script="pm3sfdmn01||/opt/wombat/us/mahwah/scripts/bin/morning_checks/morningChecksSuperFeed.sh"
#mahwah_script="pm3sfdmc18a||/opt/wombat/scripts/bin/morning_checks/morningChecksSuperFeed.sh"

# miscellaneous check scripts
utpxdp_script="njwameup01a||/opt/wombat/scripts/bin/morning_checks/njwameup01_check.sh"
xdp_script="pm3sfdmn01|pm3sfdmn02|/opt/wombat/us/weehaken/staging/scripts/bin/xdpcheck.sh"
xdpftp_script="pm3sfdmn01|pm3sfdmn02|/opt/wombat/us/weehaken/staging/scripts/bin/xdpcheck.sh -ftp"

##### backup destinations - local backup path | remote archive server | remote archive path
ny2_prod_archive="ny2/production/log/morning_checks/||"
ny2_staging_archive="ny2/staging/log/morning_checks/||"
weehaken_archive="weehaken/production/log/morning_checks/||"
cermak_archive="cermak/production/log/morning_checks/||"
mahwah_archive="mahwah/log/morning_checks/||"
utpxdp_archive="utpxdp||"
xdp_archive="xdp||"
xdpftp_archive="xdp||"

# mail headers
ny2_prod_header="[Autocheck] Superfeed (US) NY2 Production DBAC Status Check $myYearMonthDay"
ny2_staging_header="[Autocheck] Superfeed (US) NY2 Staging $runtime Status Check $myYearMonthDay"
weehaken_header="[Autocheck] Superfeed (US) Weehawken Production $runtime Status Check $myYearMonthDay"
cermak_header="[Autocheck] Superfeed (US) Cermak $runtime Status Check $myYearMonthDay"
mahwah_header="[Autocheck] Superfeed (US) Mahwah Production $runtime Status Check $myYearMonthDay"
utpxdp_header="[Autocheck] UTP/XDPLIFFEEURO Cache Superfeed-US $runtime Status Check $myYearMonthDay"
xdp_header="[Autocheck] XDPLIFFE pb1sffdh02a $runtime File Check $myYearMonthDay"
xdpftp_header="[Autocheck] XDPLIFFE FTP $runtime File Check $myYearMonthDay"

#############################################################################
# Function logmsg
# Append the log message into the log file.
#############################################################################
logmsg(){
echo `date +"%m/%d/%y %H:%M:%S "` "[$param1] - $1" >> $logfile
}

############################################################################################
# Function in_list
# Check if a value exists in an array
############################################################################################
in_list() {
    for i in ${mc_servers[@]}; do
        if [ $i == $1 ];  then
            return 1
        fi
    done
    return 0
}
############################################################################################
############################################################################################
# main program
#logmsg "Start of script" # moved down further

# only run in pm3sfdmn01 or pm3sfdmn02
if [ "$myhost" != "pny2mamgt03" ] && [ "$myhost" != "pm3sfdmn02" ]; then
   echo "[WARNING] - This script can only be run on pny2mamgt01v or pm3sfdmn02!"
   logmsg "[WARNING] - This script can only be run on pny2mamgt01v or pm3sfdmn02! - Terminating"
   exit 1
fi

# check for parameter value
if [ -z $param1 ]; then
    echo "[ERROR] - Missing environment parameter"
    echo "sample autochecks: cermak, mahwah, staging, weehaken"
    echo "sample morning checks: utpxdp, xdp, xdpftp"
    logmsg "[ERROR] - Missing environment parameter - Terminating"
    exit 1;
else
    if `in_list $param1`; then
        # not in list of environment that can be checked
        $param1=""
        echo "[ERROR] - [$param1] is not in the list of allowed environments"
        logmsg "[ERROR] - [$param1] is not in the list of allowed environments - Terminating"
        exit 1;
    fi
fi

logmsg "Start of script"
# get required values - host | morning check script
source_val=$1_script
mymcsource=${!source_val}
hostname=`echo "$mymcsource" | cut -d'|' -f1`   # source of morning checks
hostname_bkup=`echo "$mymcsource" | cut -d'|' -f2`   # source of morning checks (bkup)
scriptname=`echo "$mymcsource"| cut -d'|' -f3`  # script to be run in $hostname

# get required values - local backup path | remote archive server | remote archive path
backup_val=$1_archive
mybackupsource=${!backup_val}
echo "MYBACKUPSOURCE = [$mybackupsource]"
localbackupfolder=`echo "$mybackupsource" | cut -d'|' -f1`
remotebackupserver=`echo "$mybackupsource" | cut -d'|' -f2`
remotebackupfolder=`echo "$mybackupsource" | cut -d'|' -f3`

emailheader_val=$1_header
emailsubject=${!emailheader_val}                # email subject header

# execute check script and save locally
logmsg "Executing check $mymcsource"
if [ `hostname -s` != "$hostname" ] && [ `hostname -s` != "$hostname_bkup" ]; then
    ssh -qn $hostname "$scriptname" > $local_archive_path/$localbackupfolder/$param1-early_morning_check.out.$myYearMonthDayHourMinSec
else
    $scriptname > $local_archive_path/$localbackupfolder/$param1-early_morning_check.out.$myYearMonthDayHourMinSec
fi
logmsg "Saved at $local_archive_path/$localbackupfolder/$param1-early_morning_check.out.$myYearMonthDayHourMinSec"

if [ -n "$remotebackupserver" ]; then
    # create a gzip file to be moved and saved on the remote server
    # gzip -9 -c xdpftp-morning_check.out.20130505194529 > xdpftp-morning_check.out.20130505194529.gz
    gzip -9 -c $local_archive_path/$localbackupfolder/$param1-early_morning_check.out.$myYearMonthDayHourMinSec > $local_archive_path/$localbackupfolder/$param1-early_morning_check.out.$myYearMonthDayHourMinSec.gz

    scp $local_archive_path/$localbackupfolder/$param1-early_morning_check.out.$myYearMonthDayHourMinSec.*  $remotebackupserver:$remotebackupfolder/
    err=$?
    echo "Sending to $remotebackupserver:$remotebackupfolder"
    echo "ERRORCODE [$err]"
    logmsg "SCP Errorcode - [$err] - Sending to $remotebackupserver:$remotebackupfolder"

    # TODO. create a way to save 6 months of data and delete older ones
    # find $local_archive_path/$localbackupfolder -mtime +180 -type f -name $param1-morning_check.out.*gz -delete

else
    # debug me here
    #echo "SKIPPING REMOTE ARCHIVE"
    logmsg "Remote server undefined. Skipping remote backup"
fi

# check local backup for old files and delete - for now save only 14 days worth of files; zip older than 7 days
#find $local_archive_path/$localbackupfolder -mtime +180 -type f -name $param1-morning_check.out.*gz -delete
for mynewfile in `find $local_archive_path/$localbackupfolder -mtime +14 -type f -name $param1-early_morning_check.out.*gz`; do
    rm $mynewfile
    logmsg "$mynewfile has been removed from local archive"
done;

for mynewfile in `find $local_archive_path/$localbackupfolder -mtime +7 -type f -name $param1-early_morning_check.out.* | grep -v ".gz"`; do
    gzip -q -9 $mynewfile
    logmsg "$mynewfile has been archived locally"
done;

# email results
logmsg "Sending email to $BRECIPIENTS and $TRECIPIENTS"
echo "
01am Expect EU DBACS to be up
03am Expect TSX/TVITCH to be up
06am Expect Everything to be up" > /tmp/dbac_text
cat $local_archive_path/$localbackupfolder/$param1-early_morning_check.out.$myYearMonthDayHourMinSec >> /tmp/dbac_text
cat /tmp/dbac_text | mail -r vela@pny2mamgt01v.velatt.com -s "$emailsubject" -b $BRECIPIENTS $TRECIPIENTS
#cat $local_archive_path/$localbackupfolder/$param1-early_morning_check.out.$myYearMonthDayHourMinSec | mail -r vela@pny2mamgt01v.velatt.com -s "$emailsubject" -b $BRECIPIENTS $TRECIPIENTS

logmsg "End of script ~8)."

# end of script
#############################################################################################!/bin/bash
############################################################################################
# Roberto Omana
# NYFIX, Inc.
# 7:21 PM Friday, August 17, 2012
# 3:16 PM Tuesday, July 30, 2013
############################################################################################
# Name          : runUSMorningChecks.sh
# LogFile       : /tmp/runUSMorningChecks.log
# Requirement   : $1 = environment as defined under 'morning check sources'
# Output        : copy of check output in $local_archive_path/$mybackupfolder/
#               : -- uses the source as prefix and `date +%Y%m%d%H%M%S` as suffix to avoid accidental overwriting
#
# History :
# --------
# Initials   Date           Description
# --------   ----------     ------------
# romana     08/17/2012     initial version
# romana     04/24/2013     bugfix; typo errors
# romana     05/06/2013     updated scripts. now using actual server sources.
# romana     05/08/2013     updated subject headers + archive folders + utpxdp script; added archive maintenance
# romana     05/09/2013     bugfix; adjusted staging to run in pm1sfdmn01v instead
# romana     05/15/2013     added remote archiving + maintenance
# romana     07/30/2013     bugfix; prevent script from ssh to pm1sfdmn01v
# adionisio  07/25/2014     changed archiving and path for migration to pm3sfdmn01; added allowance to run in bkup repo
############################################################################################
# This script consolidated the morning checks for any box accesible to pm3sfdmn01 or pm3sfdmn02
# TBD: 1. where to backup historical checks
############################################################################################
# immediately save the parameter used
param1=$1

# email recepients
#BRECIPIENTS="r.omana@srtechlabs.com"
BRECIPIENTS="romana@velatt.com"
#BRECIPIENTS="acruz@velatt.com"
#TRECIPIENTS="acruz@velatt.com"
#TRECIPIENTS="r.omana@srtechlabs.com"
#TRECIPIENTS="managedservices@srtechlabs.com"
TRECIPIENTS="managedservices@velatradingtech.com"

# constants
#temp_path="/tmp"
temp_path="/opt/wombat/global_scripts/log"
local_archive_path="/opt/wombat/us" # change archive path here
logfile="$temp_path/runUSMorningChecks.log"
myhost=`hostname -s`
ARCHIVE_HOST=10.188.64.159 # <--- this is the IP of pm2sfdmn01v


# variables
rundate=`date`
runtime=`date +%I%M%p`
myYearMonthDay=`date +%Y%m%d`
myYearMonthDayHourMinSec=` date +%Y%m%d%H%M%S`
mc_servers="ny2_prod cermak mahwah ny2_staging weehaken utpxdp xdp xdpftp"

#############################################################################
# to add more checks
# 1. add a unique source in mc_servers list
# 2. add the source and script name
#    format: <server>|<executable script] - note that server should be accesible to pm3sfdmn01
# 3. add backup destination - which should be under $local_archive_path
# 4. add a mail header
#############################################################################

##### morning check sources | archive server | script names
ny2_prod_script="pny2mamgt01v||/opt/wombat/us/ny2/production/scripts/bin/morning_checks/earlyMorningChecksSuperFeed.sh"

# old script - staging="njwamstc08|/opt/wombat/scripts/bin/morning_checks/morningChecksSuperFeed.sh"
#staging_script="pm3sfdmn01|pm3sfdmn02|/opt/wombat/us/weehaken/staging/scripts/bin/morning_checks/morningChecksSuperFeed.sh"
ny2_staging_script="pny2mamgt01v||/opt/wombat/us/ny2/staging/scripts/bin/morning_checks/morningChecksSuperFeed.sh"

# old script weehaken="njwammcp04b|/opt/wombat/scripts/bin/morning_checks/morningChecksSuperFeed.sh"
#weehaken_script="njwammcp27a|/opt/wombat/scripts/bin/morning_checks/morningChecksSuperFeed.sh"
weehaken_script="pm3sfdmn01|pm3sfdmn02|/opt/wombat/us/weehaken/production/scripts/bin/morning_checks/morningChecksSuperFeed.sh"

# old script- cermak="pckmcwom04b|/opt/wombat/scripts/bin/morning_checks/morningChecksSuperFeed.sh"
cermak_script="pny2mamgt01v||/opt/wombat/us/cermak/production/scripts/bin/morning_checks/morningChecksSuperFeed.sh"

# old script - mahwah="pm3sfdut01b|/opt/wombat/scripts/bin/morning_checks/morningChecksSuperFeed.sh"
mahwah_script="pm3sfdmn01||/opt/wombat/us/mahwah/scripts/bin/morning_checks/morningChecksSuperFeed.sh"
#mahwah_script="pm3sfdmc18a||/opt/wombat/scripts/bin/morning_checks/morningChecksSuperFeed.sh"

# miscellaneous check scripts
utpxdp_script="njwameup01a||/opt/wombat/scripts/bin/morning_checks/njwameup01_check.sh"
xdp_script="pm3sfdmn01|pm3sfdmn02|/opt/wombat/us/weehaken/staging/scripts/bin/xdpcheck.sh"
xdpftp_script="pm3sfdmn01|pm3sfdmn02|/opt/wombat/us/weehaken/staging/scripts/bin/xdpcheck.sh -ftp"

##### backup destinations - local backup path | remote archive server | remote archive path
ny2_prod_archive="ny2/production/log/morning_checks/||"
ny2_staging_archive="ny2/staging/log/morning_checks/||"
weehaken_archive="weehaken/production/log/morning_checks/||"
cermak_archive="cermak/production/log/morning_checks/||"
mahwah_archive="mahwah/log/morning_checks/||"
utpxdp_archive="utpxdp||"
xdp_archive="xdp||"
xdpftp_archive="xdp||"

# mail headers
ny2_prod_header="[Autocheck] Superfeed (US) NY2 Production DBAC Status Check $myYearMonthDay"
ny2_staging_header="[Autocheck] Superfeed (US) NY2 Staging $runtime Status Check $myYearMonthDay"
weehaken_header="[Autocheck] Superfeed (US) Weehawken Production $runtime Status Check $myYearMonthDay"
cermak_header="[Autocheck] Superfeed (US) Cermak $runtime Status Check $myYearMonthDay"
mahwah_header="[Autocheck] Superfeed (US) Mahwah Production $runtime Status Check $myYearMonthDay"
utpxdp_header="[Autocheck] UTP/XDPLIFFEEURO Cache Superfeed-US $runtime Status Check $myYearMonthDay"
xdp_header="[Autocheck] XDPLIFFE pb1sffdh02a $runtime File Check $myYearMonthDay"
xdpftp_header="[Autocheck] XDPLIFFE FTP $runtime File Check $myYearMonthDay"

#############################################################################
# Function logmsg
# Append the log message into the log file.
#############################################################################
logmsg(){
echo `date +"%m/%d/%y %H:%M:%S "` "[$param1] - $1" >> $logfile
}

############################################################################################
# Function in_list
# Check if a value exists in an array
############################################################################################
in_list() {
    for i in ${mc_servers[@]}; do
        if [ $i == $1 ];  then
            return 1
        fi
    done
    return 0
}
############################################################################################
############################################################################################
# main program
#logmsg "Start of script" # moved down further

# only run in pm3sfdmn01 or pm3sfdmn02
if [ "$myhost" != "pny2mamgt03" ] && [ "$myhost" != "pm3sfdmn02" ]; then
   echo "[WARNING] - This script can only be run on pny2mamgt01v or pm3sfdmn02!"
   logmsg "[WARNING] - This script can only be run on pny2mamgt01v or pm3sfdmn02! - Terminating"
   exit 1
fi

# check for parameter value
if [ -z $param1 ]; then
    echo "[ERROR] - Missing environment parameter"
    echo "sample autochecks: cermak, mahwah, staging, weehaken"
    echo "sample morning checks: utpxdp, xdp, xdpftp"
    logmsg "[ERROR] - Missing environment parameter - Terminating"
    exit 1;
else
    if `in_list $param1`; then
        # not in list of environment that can be checked
        $param1=""
        echo "[ERROR] - [$param1] is not in the list of allowed environments"
        logmsg "[ERROR] - [$param1] is not in the list of allowed environments - Terminating"
        exit 1;
    fi
fi

logmsg "Start of script"
# get required values - host | morning check script
source_val=$1_script
mymcsource=${!source_val}
hostname=`echo "$mymcsource" | cut -d'|' -f1`   # source of morning checks
hostname_bkup=`echo "$mymcsource" | cut -d'|' -f2`   # source of morning checks (bkup)
scriptname=`echo "$mymcsource"| cut -d'|' -f3`  # script to be run in $hostname

# get required values - local backup path | remote archive server | remote archive path
backup_val=$1_archive
mybackupsource=${!backup_val}
echo "MYBACKUPSOURCE = [$mybackupsource]"
localbackupfolder=`echo "$mybackupsource" | cut -d'|' -f1`
remotebackupserver=`echo "$mybackupsource" | cut -d'|' -f2`
remotebackupfolder=`echo "$mybackupsource" | cut -d'|' -f3`

emailheader_val=$1_header
emailsubject=${!emailheader_val}                # email subject header

# execute check script and save locally
logmsg "Executing check $mymcsource"
if [ `hostname -s` != "$hostname" ] && [ `hostname -s` != "$hostname_bkup" ]; then
    ssh -qn $hostname "$scriptname" > $local_archive_path/$localbackupfolder/$param1-early_morning_check.out.$myYearMonthDayHourMinSec
else
    $scriptname > $local_archive_path/$localbackupfolder/$param1-early_morning_check.out.$myYearMonthDayHourMinSec
fi
logmsg "Saved at $local_archive_path/$localbackupfolder/$param1-early_morning_check.out.$myYearMonthDayHourMinSec"

if [ -n "$remotebackupserver" ]; then
    # create a gzip file to be moved and saved on the remote server
    # gzip -9 -c xdpftp-morning_check.out.20130505194529 > xdpftp-morning_check.out.20130505194529.gz
    gzip -9 -c $local_archive_path/$localbackupfolder/$param1-early_morning_check.out.$myYearMonthDayHourMinSec > $local_archive_path/$localbackupfolder/$param1-early_morning_check.out.$myYearMonthDayHourMinSec.gz

    scp $local_archive_path/$localbackupfolder/$param1-early_morning_check.out.$myYearMonthDayHourMinSec.*  $remotebackupserver:$remotebackupfolder/
    err=$?
    echo "Sending to $remotebackupserver:$remotebackupfolder"
    echo "ERRORCODE [$err]"
    logmsg "SCP Errorcode - [$err] - Sending to $remotebackupserver:$remotebackupfolder"

    # TODO. create a way to save 6 months of data and delete older ones
    # find $local_archive_path/$localbackupfolder -mtime +180 -type f -name $param1-morning_check.out.*gz -delete

else
    # debug me here
    #echo "SKIPPING REMOTE ARCHIVE"
    logmsg "Remote server undefined. Skipping remote backup"
fi

# check local backup for old files and delete - for now save only 14 days worth of files; zip older than 7 days
#find $local_archive_path/$localbackupfolder -mtime +180 -type f -name $param1-morning_check.out.*gz -delete
for mynewfile in `find $local_archive_path/$localbackupfolder -mtime +14 -type f -name $param1-early_morning_check.out.*gz`; do
    rm $mynewfile
    logmsg "$mynewfile has been removed from local archive"
done;

for mynewfile in `find $local_archive_path/$localbackupfolder -mtime +7 -type f -name $param1-early_morning_check.out.* | grep -v ".gz"`; do
    gzip -q -9 $mynewfile
    logmsg "$mynewfile has been archived locally"
done;

# email results
logmsg "Sending email to $BRECIPIENTS and $TRECIPIENTS"
echo "
01am Expect EU DBACS to be up
03am Expect TSX/TVITCH to be up
06am Expect Everything to be up" > /tmp/dbac_text
cat $local_archive_path/$localbackupfolder/$param1-early_morning_check.out.$myYearMonthDayHourMinSec >> /tmp/dbac_text
cat /tmp/dbac_text | mail -r vela@pny2mamgt01v.velatt.com -s "$emailsubject" -b $BRECIPIENTS $TRECIPIENTS
#cat $local_archive_path/$localbackupfolder/$param1-early_morning_check.out.$myYearMonthDayHourMinSec | mail -r vela@pny2mamgt01v.velatt.com -s "$emailsubject" -b $BRECIPIENTS $TRECIPIENTS

logmsg "End of script ~8)."

# end of script
############################################################################################
