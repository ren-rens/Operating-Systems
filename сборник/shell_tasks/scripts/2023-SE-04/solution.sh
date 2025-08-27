#!/bin/bash

if [[ "${#}" -ne 1 ]]; then
    echo "1 argument needed!"
    exit 1
fi

if [[ ! -d "${1}" ]]; then
    echo "Argument must be a directory!"
    exit 2
fi

files=$(mktemp)

while read file; do
    current_sum=$(sha256sum "${file}" | awk '{ print $1 }')
    echo "${current_sum} ${file}" >> "${files}"
done < <(find "${1}" -type f)

sha_sums_directory="${1}sha_sums"
mkdir -p "${sha_sums_directory}"

while read sum; do
    file_to_read=$(cat "${files}" | grep "${sum}" | head -n 1 | awk '{ print $2 }')
    base_name=$(basename "${file_to_read}")
    dest="${sha_sums_directory}/${base_name}"

    cp "${file_to_read}" "${dest}"

    while read file; do
        directory=$(dirname "${file}")

        rm -f "${file}"
        ln -s "${dest}" "${file}"
    done < <(cat "${files}" | grep "${sum}" | awk '{ print $2 }')
done < <(cat "${files}" | awk '{ print $1 }' | sort | uniq)

rm "${files}"
