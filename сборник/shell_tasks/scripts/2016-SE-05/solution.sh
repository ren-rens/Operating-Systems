#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "Two arguments needed"
    exit 1
fi

if [[ ! -f "${1}" ]] || [[ ! -f "${2}" ]]; then
    echo "The arguments must be files!"
    exit 2
fi

rows1=$(cat "${1}" | wc -l)
rows2=$(cat "${2}" | wc -l)

if [[ "${rows1}" -lt "${rows2}" ]]; then
    file="${2}"
else
    file="${1}"
fi

songs=$(mktemp)

while read line; do
    echo "${line}" | cut -d '-' -f 2- >> "${songs}"
done< <(cat "${file}")

touch "${file}.songs"

while read line; do
    echo "${line}" >> "${file}.songs"
done< <(cat "${songs}" | sort)

rm "${songs}"

exit 0
