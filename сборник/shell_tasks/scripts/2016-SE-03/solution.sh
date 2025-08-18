#!/bin/bash
if [[ "${USER}" != "root" ]]; then
    echo "not root!"
    exit 1
fi
  

if [[ $# != 1 ]] || [[ ! -f "${1}" ]]; then
    echo "one file argument needed!"
    exit 2
fi
 
while read line; do
    homedir=$(echo "${line}" | cut -d ':' -f 6)
    user=$(echo "${line}" | cut -d ':' -f 1)
    if [[ "${homedir}" == "" ]]; then
        echo "${user} \n"
    fi
done< <(cat "${1}")

exit 0
