#!/bin/bash


killapp(){

#if we get here , the application refused to shutdown

kill -9 `cat /var/run/myapp.pid`

}

case $1 in
	start) 
		echo starting myapp...
		/usr/local/bin/myapp &
		echo $! > /ver/run/myapp.pid ;;
	stop)   
		echo stopping myapp...
		timeout -s 15 k 10 20 /scripts/stop.myapp
		res=$?
		echo "`date`: myapp returned with exit code $res" >> /ver/log/myapp.log
		case $res in
			0) echo "My app stopped by itself." ;;
	              124) echo Myapp timed out whe waiting 
			   killapp ;;
		      137) echo myapp was killed when timing out
			   killapp ;;
		        *) echo my app exited with a return code of $res ;;
		esac
		rm -f /var/run/myapp.pid;;
	*)      echo "Usage `basename $0` start | stop"	     
		exit 2 
esac
