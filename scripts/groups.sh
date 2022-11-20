#!/bin/bash

get_groupname(){

[ ! -z "$1" ] && getent group $@ | cut -d: -f1
}

get_groupid(){

[ ! -z "$1" ] && getent group $@ | cut -d: -f3

}


get_username(){

[ ! -z "$@" ] && getent passwd $1 | cut -d: -f1

}

get_userid(){

[ ! -z "$1" ] && getent passwd $1 | cut -d: -f3 

}

get_user_group_names(){

[ ! -z "$1" ] && groups $@ | cut -d: -f2


}

get_user_group_ids(){

get_user_group_names $@ | while read groups;do
	get_groupid $groups;done
}

get_primary_group_id(){

[ ! -z "$1" ] && getent passwd $1 | cut -d: -f4

}


get_primary_group_name(){


[ ! -z "$1" ] && get_groupname `get_primary_group_id $@`

}


show_user(){

[ $# -gt 0 ] && getent passwd $@ | cut -d: -f1,5

}

show_groups(){

for uid in $@;do
	echo User $uid : Primary group is `get_primary_group_name $uid`
	printf "Additional groups: "
	for gid in `id -G $uid | cut -d" " -f2-`;do
		printf "%s " `get_groupname $gid`;done
	echo;done

}


show_group_members(){

for sgid in `get_groupid $@`;do
	echo
	echo Primary members of the group `get_groupname $sgid`
	show_user `getent passwd | cut -d: -f1,4 | grep ":${sgid}$" | cut -d: -f1`
	echo secondary members of the group `get_groupname $sgid`
	show_user `getent group $sgid | cut -d: -f4 | tr ',' ' '`;done


}


USERNAME=${1:-$LOGNAME}
echo User $USERNAME is in these groups: `id -Gn $USERNAME`
show_groups $username
show_group_members `id -G $USERNAME`




