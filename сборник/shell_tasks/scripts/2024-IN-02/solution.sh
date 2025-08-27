#!/bin/bash

if [[ "${#}" -ne 2 ]]; then
    echo "2 arguments needed!"
    exit 1
fi

while read file; do
    class=$(echo "${file}" | cut -d ' ' -f 2)

    if echo "${file}" | grep -q -E ": [a-zA-Z ,]+"; then
        parent=$(echo "${file}" | cut -d ' ' -f 4- | sed "s/public|private|protected//" | tr -d ',')
        echo "${class} ${parent}" >> "${2}"
    fi

    while read line; do
        child=$(echo "${line}" | awk '{ print $NF }')
        parent=$(echo "${line}" | awk '{ print $1 }')

        if [[ "${child}" == "${parent}" ]]; then
            #echo "${child}" >> "${2}"
            continue
        fi

        echo "${child} ${parent}" >> "${2}"

    done < <(cat "${file}")

done < <(find "${1}" -type f | grep -E "^class [[:alnum:]]+")
