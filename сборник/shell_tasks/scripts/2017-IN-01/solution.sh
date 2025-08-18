#!/bin/bash

if [[ $# -ne 3 ]]; then
    echo "3 arguments needed!"
    exit 1
fi

if [[ ! -f ""${1} ]]; then
    echo "1st argument must be a file!"
    exit 2
fi

str1_seen=$(grep -E "^${2}=[[:alnum:] ]*$" "${1}" | wc -l)
if [[ "${str1_seen}" -ne 1 ]];  then
    echo "1st string must be seen once in the file!"
    exit 3
fi

str2_seen=$(grep -E "^${3}=[[:alnum:] ]*$" "${1}" | wc -l)
if [[ "${str2_seen}" -eq 0 ]]; then
    echo "No rows that have string2!"
    exit 0;
fi

 value1=$(grep -E "^${2}=[[:alnum:] ]*$" "${1}" | cut -d '=' -f 2)
value2=$(grep -E "^${3}=[[:alnum:] ]*$" "${1}" | cut -d '=' -f 2)

 values=$(mktemp)

 while read -d ' ' term_value2; do
    while read -d ' ' term_value1; do
        if [[ "${term_value1}" == "${term_value2}" ]]; then
            echo "${term_value2}" >> "${values}"
            break
        fi
    done< <(echo "${value1}")
done< <(echo "${value2}")

 while read line; do
    sed -i -E "s/^${3}=([[:alnum:] ]*)(${line} )([[:alnum:] ]*)$/${3}=\1\3/" "${1}"
done< <(cat "${values}")

 rm "${values}"
