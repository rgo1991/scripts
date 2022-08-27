#!/bin/bash
#
# Script to pull the OCC Series file from njwamstc05 to the repository server, wombat-sf01
#

if [ `hostname -s` != "wombat-sf01" ];
then
   echo "This script can only be run on wombat-sf01!"
   exit 1
fi

REMOTE_OCC_FILE_DIR=/opt/wombat/scripts/data/v5/
LOCAL_OCC_FILE_DIR=/opt/wombat/us/weehaken/staging/log/store/occ_series

DATE=`date +%Y%m%d`
TODAY=`date +%A`
YESTERDAY=`date -d "1 day ago" +%Y%m%d`
TWO_DAYS_AGO=`date -d "2 days ago" +%Y%m%d`

OUTPUT_FILES="opra_1_2_occ.sym opra_3_4_occ.sym opra_5_6_occ.sym opra_7_8_occ.sym opra_9_10_occ.sym opra_11_12_occ.sym opra_13_14_occ.sym opra_15_16_occ.sym opra_17_18_occ.sym opra_19_20_occ.sym opra_21_22_occ.sym opra_23_24_occ.sym"

RESULT="ALL OK"
REASON=""

echo " "
echo "**** Running the Check OCC File Script ****"
echo "Started at: "`date`

echo "Checking the OCC script input xml file"

latest_series_xml=`ls -ltr $LOCAL_OCC_FILE_DIR | tail -n 1`

file_size=`echo $latest_series_xml | awk '{print $5}'`
file_date=`echo $latest_series_xml | awk '{print $9}' | awk -F'.' '{print $4}'`

# Check that the file size is not 0
#
if [ "$file_size" == "0" ]
then
   RESULT="*** CRITICAL ***"
   REASON="${REASON}Input series xml file size is 0.\n"
fi

# Check that the file's date is correct
#
if [ "$TODAY" == "Monday" ]
then
   if [ "$file_date" != "$YESTERDAY" ] && [ "$file_date" != "$TWO_DAYS_AGO" ]
   then
      RESULT="*** CRITICAL ***"
      REASON="${REASON}Date of input series xml is not equal to expected date.\n"
   fi
else
   if [ "$file_date" != "$TODAY" ]
   then
      RESULT="*** CRITICAL ***"
      REASON="${REASON}Date of input series xml is not equal to expected date.\n"
   fi
fi

echo "Checking the size of the input xml file on the repository versus on the remote host, njwamstc23"

# First, check that the file exists
#
remote_check=`ssh -q njwamstc23 "ls -l /opt/wombat/scripts/data | grep series.dat.xml"`

if [ "$remote_check" == "" ]
then
   RESULT="*** CRITICAL ***"
   REASON="${REASON}File series.dat.xml does not exist on njwamstc23.\n"
else
   # File exists; compare the size
   #
   repository_xml=`ls -ltr $LOCAL_OCC_FILE_DIR | tail -n 1`
   repository_file_size=`echo $repository_xml | awk '{print $5}'`
   repository_file_name=`echo $repository_xml | awk '{print $9}'`

   remote_xml=`ssh -q njwamstc23 "ls -l /opt/wombat/scripts/data/series.dat.xml"`
   remote_file_size=`echo $remote_xml | awk '{print $5}'`

   if [ "$repository_file_size" != "$remote_file_size" ]
   then
      RESULT="*** CRITICAL ***"
      REASON="${REASON}File series.dat.xml on njwamstc23 does not match size of $repository_file_name on wombat-sf01.\n"
   fi
fi

echo "Checking the OCC script output files on njwamstc23"

for output_file in $OUTPUT_FILES;
do
   remote_check=`ssh -q njwamstc23 "ls -l $REMOTE_OCC_FILE_DIR/$output_file"`

   file_size=`echo $remote_check | awk '{print $5}'`
   file_date=`echo $remote_check | awk '{print $6$7}'`

   # Check that the file size is not 0
   #
   if [ "$file_size" == "0" ]
   then
      RESULT="*** CRITICAL ***"
      REASON="${REASON}Output file $output_file - size is 0.\n"
   fi

   # Check that the file's date is correct
   #
   if [ "$file_date" != "`date +%b%d`" ]
   then
      RESULT="*** CRITICAL ***"
      REASON="${REASON}Output file $output_file - date, $file_date, is not equal to expected date, `date +%b%d`.\n"
   fi

done

echo -e $REASON | mail -s "Auto Check: SuperFeed Staging OCC File - $RESULT" kevin.solinger@wombatfs.com

exit
echo "Ended at: "`date`
echo "**** FINISHED - Running the OCC File Archive Script ****"
echo " "
