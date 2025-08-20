#!/bin/bash

if [[ $# -ne 1 ]] || [[ ! -f "${1}" ]]; then
    echo "One argument file needed!"
    exit 1
fi

if [[ $(grep "SOA" "${1}" | wc -l) -ne 1 ]]; then
    echo "Wrong input file!"
    exit 2
fi

curr_date=$(date +"%Y%m%d")
for i in "${@}"; do
    if grep -q "(" "${1}"; then
        # second type (multiline SOA)
        serial=$(grep -A 2 "SOA" "${1}" | grep "serial" | awk '{print $1}')

        serial_date=$(grep -A 2 "SOA" "${1}" | grep "serial" | awk '{print $1}' | sed -E "s/([0-9]{8})[0-9]{2}/\1/")
        count=$(grep -A 2 "SOA" "${1}" | grep "serial" | awk '{print $1}' | sed -E "s/([0-9]{8})([0-9]{2})/\2/")

    else
        # first type (one-line SOA)
        serial=$(grep -E "SOA" "${1}")

        # check if TTL is present
        if grep -qE "[a-z.[0-9]]* [0-9]+ IN SOA" "${1}"; then
            # with TTL
            serial=$(grep "SOA" "${1}" | awk '{print $7}')
        else
            # without TTL
            serial=$(grep "SOA" "${1}" | awk '{print $6}')
        fi

        serial_date=$(echo "${serial}" | sed -E "s/([0-9]{8})([0-9]{2})/\1/")
        count=$(echo "${serial}" | sed -E "s/([0-9]{8})([0-9]{2})/\2/")
    fi

    if [[ "${curr_date}" -gt "${serial_date}" ]]; then
        # change date, make count 0
        new_serial="${curr_date}00"
    else
        # increment count
        if [[ "${count}" -eq 99 ]]; then
            echo "count is 99!"
            exit 3
        fi

        count1=$(echo "${count} / 10" | bc)
        count2=$(echo "${count} % 10" | bc)

        if [[ "${count2}" -eq 9 ]]; then
            count2=0
            count1=$((count1 + 1))
        else
            count2=$((count2 + 1))
        fi

        new_count="${count1}${count2}"
        new_serial="${serial_date}${new_count}"
    fi

    sed -iE "s/${serial}/${new_serial}/" "${1}"
done
