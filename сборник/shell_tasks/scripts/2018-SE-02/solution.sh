#!/bin/bash

if [[ "${#}" -ne 2 ]]; then
    echo "2 args needed!"
    exit 1
fi

if [[ ! -f "${1}" || ! -d "${2}" ]]; then
    echo "First arg must be a file, second a directory!"
    exit 2
fi

mkdir -p "${2}"

touch "${2}/dict.txt"

key=0
while read line; do
    curr="${line}"

    if echo "${curr}" | grep "(" >/dev/null; then
        curr=$(echo "${curr}" | cut -d '(' -f 1 | cut -d ' ' -f -2)
    fi

    if grep -q "${curr}" "${2}/dict.txt"; then
        continue
    fi

    key=$(echo "${key}+1" | bc)

    echo "${curr};${key}" >> "${2}/dict.txt"
done < <(cut -d ':' -f 1 "${1}")

while read line; do
    curr=$(echo "${line}" | cut -d ';' -f 1)

    if echo "${curr}" | grep "(" >/dev/null; then
        curr=$(echo "${curr}" | cut -d '(' -f 1)
    fi

    number=$(echo "${line}" | cut -d ';' -f 2)
    touch "${2}/${number}.txt"

    while read human; do
        echo "${human}" >> "${2}/${number}.txt"
    done < <(grep "${curr}" "${1}")

done < "${2}/dict.txt"
