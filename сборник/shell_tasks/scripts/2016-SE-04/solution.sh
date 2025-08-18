#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "Two arguments needed!"
fi

if find . -mindepth 2; then
    echo "Current dir must consist only files!"
    exit 2
fi

if ! echo "${1}" | grep -q -E "^([1-9]*[0-9]+)|0$" || ! echo "${2}" | grep -q -E "^([1-9]*[0-9]+)|0$"; then
    echo "Args should be numbers!";
    exit 3
fi

if [[ ! -e a ]]; then
    mkdir a
fi

if [[ ! -e b ]]; then
    mkdir b
fi

if [[ ! -e c ]]; then
    mkdir c
fi

while read file; do
    # rows of file -> move to dir
    rows=$(cat "${file}" | wc -l)
    
    if [[ "${rows}" -lt "${1}" ]]; then
        mv "${file}" a
    elif [[ "${rows}" -ge "${1}" ]] && [[ "${rows}" -le "${2}" ]]; then
        mv "${file}" b
    else
        mv "${file}" c
    fi
    
done< <(find . -maxdepth 1 -type f)

exit 0
