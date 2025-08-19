#!/bin/bash

n=10

if [[ "${1}" == "-n" ]]; then
    n="${2}"
    shift 2
fi

result=$(mktemp)

for i in "${@}"; do
    if [[ ! -f "${i}" ]]; then
        echo "NO such file!"
        continue
    fi
    
    while read line; do
        timestamp=$(echo "${line}" | cut -d ' ' -f 1-2)
        data=$(echo "${line}" | cut -d ' ' -f 3-)
        id=$(echo "${i}" | cut -d '.' -f 1)

        echo "${timestamp} ${id} ${data}" >> "${result}"
    done< <(cat "${i}" | tail -n "${n}")
done

cat "${result}" | sort

rm "${result}"
