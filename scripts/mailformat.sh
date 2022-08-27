#!/bin/bash
#
# Format e-mail messages
# Gets rid of carets, tabs also fold excessively long lines


# Standard check for scripts arguments

ARGS=1
E_BADARGS=65
E_NOFILE=66


if [ $# -ne $ARGS ];then
	echo "Usage: `basename $0` filename"
	exit $E_BADARGS;fi

if [ -f "$1" ];then
	file_name=$1;else
	echo "File \"$1\" doesn\'t exist"
	exit $E_NOFILE;fi

MAXWIDTH=70 	# Width to fold long lines to

# Delete carets and tabs at the beggining of lines then fold lines to $MAXWIDTH characters

sed '
s/^>//
s/^  *>//
s/^  *//
s/	*//
' $1 | fold -s --width=$MAXWIDTH # -s option to fold breaks lines at whitespace if possible

exit 0
