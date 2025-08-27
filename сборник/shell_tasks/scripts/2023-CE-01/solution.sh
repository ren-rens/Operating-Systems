#!/bin/bash

if [[ "${#}" -ne 2 ]]; then
    echo "2 args needed!"
    exit 1
fi

if [[ ! -f "${1}" ]]; then
    echo "First arg must be a file"
    exit 2
fi

star_name="No such star"
min_magnitud=0

constellations=$(mktemp)

while read line; do
    type=$(echo "${line}" | cut -d ',' -f 5)
    constellation=$(echo "${line}" | cut -d ',' -f 4)

    if [[ "${type}" == "${2}" ]]; then
        echo "${constellation}"
    fi
done < <(cat "${1}")

constellations_count=0
while read line; do
    type=$(echo "${line}" | cut -d ',' -f 5)
    current_magnitud=$(echo "${line}" | cut -d ',' -f 7)
    constellation=$(echo "${line}" | cut -d ',' -f 4)

    if [[ "${type}" == "${2}" ]]; then
        count=$(cat "${constellations}" | sort | uniq -c | grep "${constellation}")

        if [[ "${current_magnitud}" != "--" ]] &&  echo "${constellations_count} < ${count}" | bc  &&  echo "${min_magnitud} > ${current_magnitud}" | bc; then
            star_name=$(echo "${line}" | cut -d ',' -f 1)
            constellations_count=${count}
        fi
    fi

done < <(cat "${1}")

echo "${star_name}"

rm "${constellations}"
