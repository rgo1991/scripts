#!/bin/bash

INFILE=${1:-${HOME}/.mozzila/firefox/*/bookmarks.html}
state=
link=
download=/tmp/download

mkdir -p "$download" 2>/dev/null
BASE_URL=http://steve-parker.org

cat $INFILE | tr '\n' ' ' | tr '<' '\n' | tr '>' '\n' | tr '\t' ' ' | tr -s ' ' | while read tag label;do

if [ "$state" == "anchor" ] && [ ! -z "$tag" ]; then
	
	if [ "$tag" == "img" ];then
		label= ;fi
	
	if [ -z "$label" ];then
		filename=$tag;else
		filename="$tag $label";fi
	
	origname=$filename
	suffix=1

	while [ -f "${download}/${filename}" ];do
		filename="${origname}.${suffix}"
		((suffix++))
	done

	echo "retrieving $link as $filename"

	# prepend BASE_URL if not otherwise valid
	firstchar=`echo $link | cut -c1`	
	case "$firstchar" in
		"/") link=${BASE_URL}$link ;;
		"#") link=${BASE_URL}/$link;;
	esac

	wget -0 "${download}/${filename}" "$link" > /tmp/wget.$$ 2>&1
	if [ "$?" -eq 0 ];then
		ls -ld "$download/$filename";else
		echo "retrieving $link failed"
		cat /tmp/wget.$$
	fi

	state=

else

	if [ "$tag" == "A" ] || [ $tag == "a" ];then
		# only do this if not already in an anchor
		if [ "$state" != "anchor" ];then
			link=`echo $label | grep -i "href=" | tr [:blank:] '\n' | grep -io "href=.*" | cut -c6- | tr -d '"' | tr -d "'"`
			[ ! -z "$link" ] && state=anchor
		fi
	fi
fi
done

rm /tmp/wget.$$ 2> /dev/null




















	
