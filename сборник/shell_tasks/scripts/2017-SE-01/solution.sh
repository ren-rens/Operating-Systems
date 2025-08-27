#!/bin/bash

if [[ "${#}" -lt 1 ]]; then
    echo "At least 1 argument needed!"
    exit 1
fi

if [[ "${#}" -gt 2 ]]; then
    echo "No more than 2 arguments!"
    exit 2
fi

if [[ ! -d "${1}" ]]; then
    echo "First argment must be directory"
    exit 3
fi

if [[ "${#}" -eq 2 ]] && ! echo "${2}" | grep -qE "^([1-9]+[0-9]*)$|0"; then
    echo "Second arg must be a numeber!"
    exit 4
fi

#a
if [[ "${#}" -eq 2 ]]; then
    find "${1}" -type f -links +"${2}"
#b
else
    symlinks=$(mktemp)
    find "${1}" -type l >> "${symlinks}"

    while read line; do
        if ! readlink -e "${line}" >/dev/null 2>&1; then
             echo "${line}"
        fi
    done < "${symlinks}"

    rm "${symlinks}"
fi
