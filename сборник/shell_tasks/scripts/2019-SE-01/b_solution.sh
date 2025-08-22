#!/bin/bash

sums_of_digits=$(mktemp)

while read line; do

    if echo "${line}" | grep -q -v -E "^[0-9]+$|^-[0-9]+$"; then
        continue
    fi

    sum=$(echo "${line}" | grep -E -o "[0-9]" | awk '{sum+=$1} END {print sum}')

    echo "${line}:${sum}" >> "${sums_of_digits}"

done

maxSum=$(cat "${sums_of_digits}" | sort -t ':' -k 2 -n | cut -d ':' -f 1 | tail -1)
cat "${sums_of_digits}" | grep -E ":${maxSum}" | sort -t ':' -k 1 -n | cut -d ':' -f 1 | head -1

rm "${sums_of_digits}"
