#!/bin/bash

if [[ "${USER}" != "root" ]]; then
    echo "Must be root!"
    exit 1
fi

if [[ $# -ne 3 ]]; then
    echo "3 arguments needed!"
    exit 2
fi

if [[ ! -d "${1}" ]]; then
    echo "First argument must be a directory (src)!"
    exit 3
fi

if [[ -e "${2}" ]]; then
    rm -r "${2}"
    mkdir "${2}"
fi

SRC="${1}"
DST="${2}"

while read file; do
    current=""
    rel_path=${file}
    field_rel=1

    while read -d '/' src; do
        current+="${src}"
        field_rel=$((field_rel + 1))

        if [[ "${SRC}" == "${current}" ]]; then
            break
        fi
    done< <(echo "${file}")

    field_src=0
    while read -d '/' src; do
        field_src=$((field_src + 1))
    done< <(echo "${file}")

    rel_path=$(echo "${rel_path}" | cut -d '/' -f ${field_rel}-)
    src_path=$(echo "${file}" | cut -d '/' -f 1-${field_src})

    dst_path="${DST}/${rel_path}"
    mkdir -p "$(dirname ${dst_path})"
    mv "${file}" "${dst_path}"

    if [[ $(find "${src_path}" | wc -l) -eq 1 ]]; then
        rm -r "${src_path}"
    fi
done< <(find "${SRC}" -type f -name "*${3}*")
