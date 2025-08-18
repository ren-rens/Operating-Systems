#!/bin/bash

if [[ "${USER}" != "root" ]]; then
    echo "User must be root"
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "One argument needed!"
    exit 2
fi

processes=$(mktemp)
ps -e -o user=,pid=,%cpu=,%mem=,vsz=,rss=,tty=,stat=,etimes=,command= | sort -k 1 >> "${processes}"

# a)
user_count=$(cat "${processes}" | awk ' { print $1 } ' | uniq -c | grep "${1}" | awk ' { print $1 } ')

while read line; do
    count=$(echo "${line}" | awk ' { print $1 } ')
    if [[ "${count}" -gt "${user_count}" ]]; then
        user=$(echo "${line}" | awk ' { print $2 } ')
        echo "${user}"
    fi
done< <(cat "${processes}" | awk ' { print $1 } ' | uniq -c)

# b)
time=0
count=0
while read line; do
    curr_time=$(echo "${line}" | awk ' { print $9 } ')
    time=$((time + curr_time))
    count=$((count + 1))
done< <(cat "${processes}")

avg_time=$(echo "${time} / ${count}" | bc)
echo "${avg_time}"

hh=$(( avg_time / 3600 ))
mm=$(( (avg_time % 3600) / 60 ))
ss=$(( avg_time % 60 ))
printf "Average time: %02d:%02d:%02d\n" "$hh" "$mm" "$ss"

# c)
while read line; do
    time=$(echo "${line}" | awk ' { print $9 } ')
    double_avg=$(echo "${avg_time} * 2" | bc)

    if [[ "${time}" -gt "${double_avg}" ]]; then
        pid=$(echo "${line}" | awk ' { print $2 } ')
        kill -9 "${pid}"
        echo "${pid}"
    fi
done< <(cat "${processes}" | grep "${1}")

rm "${processes}"
