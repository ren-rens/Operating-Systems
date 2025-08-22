#!/bin/bash

max_value=0
unique_numbers=$(mktemp)

while read line; do

    if echo "${line}" | grep -q -v -E "^[0-9]+$|^-[0-9]+$"; then
        continue
    fi

    absolute_value=$(echo "${line}" | sed -E "s/-//")

    if [[ "${absolute_value}" -eq "${max_value}" ]]; then

        if grep -q -E "^${line}$" "${unique_numbers}"; then
            sed -E -i "s/^${line}$//" "${unique_numbers}"
        else
            echo "${line}" >> "${unique_numbers}"
        fi

        continue
    fi

    if [[ "${absolute_value}" -gt "${max_value}" ]]; then
        max_value="${absolute_value}"

        echo "${line}" > "${unique_numbers}" # this deletes the previous data in the file

    fi
done

echo "${max_value}"

cat "${unique_numbers}"

rm "${unique_numbers}"
