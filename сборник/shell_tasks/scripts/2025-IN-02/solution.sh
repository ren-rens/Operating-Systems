#!/bin/bash

if [[ "${#}" -ne 2 ]]; then
    echo "2 args needed"
    exit 1
fi

if [[ ! -f "${2}" ]]; then
    echo "Second arg must be a file!"
    exit 2
fi

if ! echo "${1}" | grep -E -q -o "[a-z]+\.[a-z]+"; then
    echo "Second arg must be a domain of the format <str>.<str>"
    exit 3
fi

result=$(mktemp)
while read user; do

    echo "; team ${user}" >> "${result}"

    while read composer; do

        while read hostname; do
            echo "${composer} IN NS ${hostname}.${1}." >> "${result}"
        done < <(cat "${2}" | grep -E "[a-z]+ [a-z]+ ${user}" | awk '{ print $1 }' | sort)

    done < <(cat "${2}" | grep -E "[a-z]+ [a-z]+ ${user}" | awk '{ print $2 }' | sort | uniq)

done < <(cat "${2}" | awk '{ print $3 }' | sort | uniq)

cat "${result}"
rm "${result}"
