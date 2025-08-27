#!/bin/bash

if [[ "${#}" -ne 2 ]]; then
    echo "2 arguments needed!"
    exit 1
fi

if [[ ! -f "${2}" ]]; then
    echo "Second argument must be a path to file!"
    exit 4
fi

result=$(echo "${1}")

if ! echo "${result}" | grep -E -q "^[-]*[0-9]+$"; then
    echo "The outside command was not executed correctly!"
    exit 3
fi

echo "$(date +'%a %Y-%m-%d %H') ${result}" >> "${2}"

current_hour=$(date +'%H' | sed 's/^0[0-9]+$//')
next_hour=$((current_hour+1))
current_day=$(date +'%a')
sum=0

while read line; do
    hour=$(echo "${line}" | cut -d ' ' -f 3)
    value=$(echo "${line}" | cut -d ' ' -f 4)

    if [[ "${hour}" -lt "${current_hour}" ]] || [[ "${hour}" -gt "${next_hour}" ]]; then
        continue
    fi

    clean_sum=$(echo "$sum" | sed 's/^0[0-9]+$//')
    clean_value=$(echo "$value" | sed 's/^0[0-9]+$//')
    sum=$(echo "${clean_sum}+${clean_value}" | bc)

done < <(cat "${2}" | grep -E "${current_day}")

avg_sum=$(echo "${sum}/2" | bc)
twice_bigger=$(echo "${avg_sum}*2" | bc)
twice_lesser=$(echo "${avg_sum}/2" | bc)

if [[ "${result}" -ge "${twice_bigger}" || "${result}" -le "${twice_lesser}" ]]; then
    echo "Current value is twice bigger/lesser than the average!"
    exit 2
fi
