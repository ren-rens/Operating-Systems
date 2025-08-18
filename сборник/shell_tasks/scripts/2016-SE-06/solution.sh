#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "One argument needed!"
    exit 1
fi

if [[ ! -f "${1}" ]]; then
    echo "Argument must be a file!"
    exit 2
fi

count=1
movies=$(mktemp)

while read line; do
    echo "${count}. ${line}" >> "${movies}"
    count=$((count + 1))
done< <(cat "${1}" | cut -d '-' -f 2-)

cat "${movies}" | sort -t ' ' -k 2

rm "${movies}"

exit 0
