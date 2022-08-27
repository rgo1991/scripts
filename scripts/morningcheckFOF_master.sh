#!/bin/bash

DATE=`date +%Y%m%d`

MORNING_CHECKS="/opt/wombat/fof/ny2/production/scripts/bin/morning_checks"
REPORT_DIR="/opt/wombat/fof/ny2/produciton/scripts/morning_check_reports"
touch $REPORT_DIR/mail_body.out

STATUS="GREEN"

# Mail lists
MANAGED_SERVICES="managedservices@tradevela.com"

# Check for any CRITICALS in subscription check
checksubscriptions(){

CRITICAL_SUB_COUNT=`grep 'manalistenc' $outChecks | grep -ic 'critical'`

if [[ $CRITICAL_SUB_COUNT -ne 0 ]];then
	STATUS="RED"
	CRITICAL_SUBS=`grep -i 'mamalistenc.*critial' $outChecks`

	echo "CRITICAL subscription(s) found: " >> $REPORT_DIR/mail_body.out
	echo "$CRITICAL_SUBS" >> $REPORT_DIR/mail.body.out
	echo " " >> $REPORT_DIR/mail_body.out
fi
	
}

# Check for lines down/part
checklinestatus(){

LINE_DOWN_COUNT=`grep -ic down $outChecks`
LINE_PART_COUNT=`grep -ic part $outChecks`

if [[ $LINE_DOWN_COUNT -ne 0 ]];then
	
	STATUS="RED"
	LINES_DOWN=`grep 'down' $outChecks`
	
	echo "lines down:" >> $REPORT_DIR/mail_body.out
	echo "$LINES_DOWN" >> $REPORT_DIR/mail_body.out
	echo " " >> $REPORT_DIR/mail_body.out

	if [[ $LINE_PART_COUNT -ne 0 ]];then	

		LINES_PART=`grep 'part' $outChecks`
		echo "Lines part:" >> $REPORT_DIR/mail_body.out
		echo "$LINES_PART" >> $REPORT_DIR/mail_body.out
		echo " " >> $REPORT_DIR/mail_body.out
	fi
elif [[ $LINE_DOWN_COUNT -eq 0 && $LINE_PART_DOWN -ne 0 ]];then

	STATUS="AMBER"
	LINES_PART=`grep 'part' $outChecks`

	echo "Lines part:" >> $REPORT_DIR/mail_body.out
	echo "$LINES_PART" >> $REPORT_DIR/mail_body.out
	echo " " >> $REPORT_DIR/mail_body.out
fi


}


# Create report output file and run the mrning check redirecting results to this file.

outChecks="$REPORT_DIR/morning_check_$DATE.out"
$MORNING_CHECKS/morningChecksFOFSuperFeed.sh > $outChecks

sleep 5

checkprocesstatus
checksubscriptions
checklinestatus
checkmessagehandlerstatus

# Display full report underneath
cat $outChecks >> $REPORT_DIR/mail_body.out

# If GREEN send to etrade; cc'ing managed services.
if [[ $STATUS == GREEN ]];then
	SUBJECT="$STATUS - FOF NY2 Production status check = $DATE"
	cat $REPORT_DIR/mail_body.out | mail -r managedservices@tradevela.com -s "$SUBJECT" $MANAGED_SERVICES
# Else only sed to managed services
else
	SUBJECT="$STATUS - PLEASE READ - FOF NY2 Production statys check = $DATE"
	cat $REPORT_DIR/mail_body.out | mail -r managedservices@tradevela.com -s "$SUBJECT" $MANAGED_SERVICES
fi

# Cleanup temporary fie
rm $REPORT_DIR/mail_body.out

exit






























