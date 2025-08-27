#!/bin/bash

home_dirs=$(mktemp)

cut -d ':' -f 6 /etc/passwd > "${home_dirs}"

first_dir="${HOME}"
latest_timestamp=0
modified_file=""
modifed_time=""
modified_user=""

while read line; do

    if [[ ! -d "${line}" || ! -r "${line}" ]]; then
        continue
    fi

    newest_file=$(find "${line}" -type f -printf "%T@ %p\n" 2>/dev/null | sort -n | tail -n 1)

    if [[ -n "$newest_file" ]]; then
        file_timestamp=$(echo "$newest_file" | awk '{print $1}')
        file_path=$(echo "$newest_file" | awk '{print $2}')

        if (( $(echo "${file_timestamp} > ${latest_timestamp}" | bc -l) )); then
            latest_timestamp="${file_timestamp}"
            modified_time=$(date -d "@$file_timestamp" "+%Y-%m-%d %H:%M:%S")
            modified_user=$(grep "${line}" /etc/passwd | cut -d ':' -f 1)
            modified_file="${file_path}"
        fi
    fi

done < "${home_dirs}"

echo "${modified_file}"
rm "${home_dirs}"
