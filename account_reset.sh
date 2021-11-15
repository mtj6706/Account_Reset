#!/bin/bash

approved=$(openssl enc -AES-256-CBC -d -in approved_usrs)
usersA=($(getent passwd | cut -d: -f1))
delUsers=()

for user in ${usersA[@]} ; do
	userApproved=$(echo "${approved[@]}" | fgrep --word-regexp "$user")
	if [ ! "$userApproved" ]; then
		echo "!!ALERT!!: There is a discrepancy between approved users and current users"
		echo "	$user is not an approved user, this user will now be killed and removed"
		delUsers+=($user)
	fi
done

for user in ${delUsers[@]}; do
	if [ ! -d "./${user}_Archive" ]; then
		mkdir "${user}_Archive"
	fi

	timestamp=$(date +"%Y-%m-%d:%T")
	tar -cvj -f "./${user}_Archive/${user}_${timestamp}.tar.bz" /home/${user}/*

	killall -u $user
	crontab -r -u $user
	userdel -r $user
done
