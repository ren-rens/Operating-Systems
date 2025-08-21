#!/bin/bash

if [[ $# -lt 2 ]]; then
    echo "At least 2 arguments needed!"
    exit 1
fi

files=$(mktemp)
replacements=$(mktemp)

for i in "${@}"; do
    if [[ "${i}" =~ ^-R[[:alnum:]]+=[[:alnum:]]+ ]]; then
        echo "${i}" | sed -E 's/-R([[:alnum:]]+=[[:alnum:]]+)/\1/'  >> "${replacements}"
    elif [[ "${i}" =~ ^-(.*) ]]; then
        echo "invalid argument!"
        exit 2
    else
        echo "${i}" >> "${files}"
    fi
done

key=$(pwgen | cut -f 1)
while read file; do
    while read line; do
        replace=$(echo "${line}" | cut -d '=' -f 1)
        replacement=$(echo "${line}" | cut -d '=' -f 2)

        sed -i -E "/^#/! s/\b${replace}\b/${replacement}${key}/g" "${file}"
    done< <(cat "${replacements}")

    sed -i -E "s/${key}//g" "${file}"
done< <(cat "${files}")

rm "${replacements}"
rm "${files}"
