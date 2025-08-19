#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "Two arguments needed!"
    exit 1
fi

if [[ ! -d "${1}" ]]; then
    echo "First argument must be a directory!"
    exit 2
fi

max_x=0
max_y=0
max_z=0
max_file=""

while read line; do
    echo "file is: ${line}"

    x=$(echo "${line}" | cut -d '-' -f 2 | cut -d '.' -f 1)
    y=$(echo "${line}" | cut -d '-' -f 2 | cut -d '.' -f 2)
    z=$(echo "${line}" | cut -d '-' -f 2 | cut -d '.' -f 3)

    if [[ max_x -gt x ]]; then
        continue;
    fi

    if [[ max_x -lt x ]]; then
        max_file="${line}"
        continue;
    elif [[ max_y -gt y ]]; then
        continue;
    elif [[ max_y -lt y ]]; then
        max_file="${line}"
    elif [[ max_z -ge z ]]; then
        continue
    else
        max_file="${line}"
    fi
done< <(find "${1}" -maxdepth 1 -type f -name "vmlinuz-[0-9]*\.[0-9]*\.[0-9]*-${2}")

echo "${max_file}"
