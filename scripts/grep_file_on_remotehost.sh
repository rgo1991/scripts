#!/bin/bash

TEMP=`mktemp`
HOST=127.0.0.1
USER='rg'

# Can run everything in the ssh pipeline.
ssh -p 2222 $USER@$HOST 'cat test.out | grep rg' > grepinremote.txt
if [ $? -eq '0' ];then
	echo success;else
	echo failure;fi

rm $TEMP

# Cat the file remotely and grep locally.
remote_grep=`ssh -p 2222 $USER@$HOST cat test.out | grep rg`
echo "$remote_grep"

# Use dd and create a file on remote host
ssh -p 2222 $USER@$HOST 'dd if=/dev/zero of=sw bs=1024 count=800'


# Create a file and echo some stuff into it
echo 'hello world' | ssh -p 2222 $USER@$HOST 'cat - >> testing.txt'


# Create a file and send a here document into it.
cat <<EOL | ssh -p 2222 $USER@$HOST 'cat > testing1.txt' 
hellow
goodbye
my
sweet
child
EOL

