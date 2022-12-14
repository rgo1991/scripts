#!/bin/bash

KEYFILE=/tmp/domains.txt
MYDOMAIN=$1

echo "$MYDOMAIN Cretion date:" | tee -a $KEYFILE
sleep 2

whois $MYDOMAIN | grep -i created | cut -d":" -f2- | tee -a $KEYFILE
sleep 2

echo $MYDOMAIN Expiration date: | tee -a $KEYFILE
sleep 2

whois $MYDOMAIN | grep "Expiration date:" | cut -d: -f2- | tee -a $KEYFILE
sleep 2

echo $MYDOMAIN DNS Servers: | tee -a $KEYFILE
sleep 2

whois $MYDOMAIN | grep "Name Server:" | cut -d: -f2- | grep -v "^$" | tee -a $KEYFILE
sleep 2 

echo "... end of $MYDOMAIN information ..." | tee -a $KEYFILE
