#!/bin/bash
pid={$1:-`pgrep -u root friartuck.sh`}
kill -3 $pid
