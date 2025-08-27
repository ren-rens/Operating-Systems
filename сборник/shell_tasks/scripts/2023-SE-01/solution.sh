#!/bin/bash

if [[ "${#}" -ne 2 ]]; then
    echo "2 args needed!"
    exit 1
fi

if [[ ! -f "${1}" ]]; then
    echo "First arg must be a file!"
    exit 2
fi

if [[ ! -d "${2}" ]]; then
    echo "Second arg must be a directory!"
    exit 3
fi

while read file; do
    while read bad_word; do
        if cat "${file}" | tr -d ',' | tr -d '.' | grep -E "\b${bad_word}\b"; then

            censored=""
            while IFS= read -r -n1 char; do
                censored+="*"
            done < <(echo -n "${bad_word}")

            sed -E -i "s/\b([^a-zA-Z0-9]?)${bad_word}[^a-zA-Z0-9]?\b/\1${censored}\1/g" "${file}"
        fi
    done < <(cat "${1}" | sort | uniq)

done < <(find "${2}" -type f -name "*.txt")
