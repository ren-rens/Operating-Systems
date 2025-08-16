#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "One argument needed!"
    exit 1
fi

if ! echo "${1}" | grep -qE "^[0-9]+$"; then
    echo "Arg must be a num!"
    exit 2
fi

 if [[ "${USER}" != "root" ]]; then
     echo "Must be root"
     exit 3
 fi

file=$(mktemp)
users_rss=$(mktemp)

ps -e -o uid=,pid=,rss= | sort -n -k 1 >> $file

while read line; do
    user=$(echo "${line}" | awk '{ print $1 }')
    rss=$(echo "${line}" | awk '{ print $3 }')
    if grep -q "^${user} " $users_rss; then
        curr=$(grep "^${user} " $users_rss | awk '{ print $2 }')
        new_rss=$((curr + rss))
        sed -i "s/^${user} ${curr}\$/${user} ${new_rss}/" $users_rss
    else
        echo "${user} ${rss}" >> $users_rss
    fi
done < <(cat $file)

while read line; do
    rss=$(echo "${line}" | awk '{ print $2 }')
    user=$(echo "${line}" | awk '{ print $1 }')

    if [[ $rss -gt $1 ]]; then
        # send signal
        pid=$(cat $file | grep "^$user" | sort -rn -k 3 | head -n 1 | awk '{print $2 }')
        # kill -9 $pid
        echo "User $user has rss $rss with biggest rss in pid: $pid"
    fi
done < <(cat $users_rss)

rm $file
rm $users_rss
