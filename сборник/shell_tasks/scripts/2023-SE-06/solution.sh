#!/bin/bash

if [[ "${#}" -ne 2 ]]; then
    echo "2 args needed!"
    exit 1
fi

if [[ ! -d "${1}" ||  -e "${2}" ]]; then
    echo "First argument must be an existing directory, second not existing!"
    exit 2
fi

mkdir -p "${2}"

while read photo; do
    new_name=$(stat -c %y "${photo}" | awk '{print $1, $2}' | sed 's/ /_/' | cut -d '.' -f 1)
    cp "${photo}" "${2}/${new_name}"
done < <(find "${1}" -type f -name "*.jpg")

# HERE WE HAVE FILLED THE LIBRARY DIRECTORY WITH THE NEW NAMES OF THE PICTURES
# THE NEW NAMES ARE THEIR DATES

begin=""
end=""
current_dir=$(mktemp)

while read line; do
    current_date=$(echo "${line}" | awk -F '/' '{ print $2 }' | cut -d '_' -f 1)

    if [[ "${begin}" == "" ]]; then
        begin="${current_date}"
        end="${begin}"
        echo "${line}" >> "${current_dir}"
        continue
    fi

    if [[ "${current_date}" == "${end}" ]]; then
        echo "${line}" >> "${current_dir}"
        continue
    fi

    plus_one_day=$(date -d "${end} + 1 day" +'%Y-%m-%d')

    if [[ "${plus_one_day}" == "${current_date}" ]]; then
        end="${plus_one_day}"
        echo "${line}" >> "${current_dir}"
        continue
    fi

    new_dir_name="${2}/${begin}_${end}"
    mkdir "${new_dir_name}"

    while read photo; do
        mv "${photo}" "${new_dir_name}"
    done < <(cat "${current_dir}")

    rm "${current_dir}"
    current_dir=$(mktemp)

    begin="${current_date}"
    end=${begin}
    echo "${line}" >> "${current_dir}"

done < <(find "${2}" -type f | sort)

if [[ -s "${current_dir}" ]]; then
    while read line; do
        new_dir_name="${2}/${begin}_${end}"

        if [[ ! -d "${new_dir_name}" ]]; then
            mkdir "${new_dir_name}"
        fi

        mv "${line}" "${new_dir_name}"
        continue
    done < <(cat "${current_dir}")

    rm -r "${current_dir}"
fi
