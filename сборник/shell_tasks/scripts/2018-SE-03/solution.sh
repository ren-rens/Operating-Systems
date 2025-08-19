#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "Two arguments needed!"
    exit 1
fi

if [[ ! -f "${1}" ]] || [[ ! -f "${2}" ]]; then
    echo "The arguments must be files!"
    exit 2
fi

while read line; do
    text=$(echo "${line}" | cut -d ',' -f 2-)
    curr_id=$(echo "${line}" | cut -d ',' -f 1)

    if grep -qE "^[0-9]+,${text}$" "${2}"; then
        id=$(grep -E "^[0-9]+,${text}$" "${2}" | cut -d ',' -f 1)

        if [[ "${id}" -gt "${curr_id}" ]]; then
            sed -iE "s/^${id},${text}$/${curr_id},${text}/" "${2}"
        fi
    else
        echo "${line}" >> "${2}"
    fi
done< <(cat "${1}")
