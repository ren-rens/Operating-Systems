#!/bin/bash

if [[ "${#}" -ne 1 ]]; then
    echo "One argument needed!"
    exit 1
fi

if [[ ! -f "${1}" ]]; then
    echo "First argument must be an existing file!"
    exit 2
fi

while read line; do
    user_owner=""
    group_owner=""
    if echo "${line}" | grep -q -E ":"; then
        user_owner=$(echo "${line}" | cut -d ' ' -f 3 | cut -d ':' -f 1)
        group_owner=$(echo "${line}" | cut -d ' ' -f 3 | cut -d ':' -f 2)
    fi

    name=$(echo "${line}" | awk -F ' ' '{ print $1 }')
    permissions=$(echo "${line}" | awk -F ' ' '{ print $NF }') # Prints the last element
    curr_type=$(echo "${line}" | awk '{ print $2 }')

    if [[ ! -e "${name}" ]] || ! stat "${name}" -c '%F' | grep -q "${curr_type}"; then

        if [[ -e "${name}" ]] && ! stat "${name}" -c '%F' | grep -q "${curr_type}"; then
            rm -r "${name}"
        fi

        if [[ "${curr_type}" == "dir" ]]; then

            if [[ "${permissions}" != "nonexistant" ]]; then
                mkdir -p "${name}" -m="${permissions}"
                continue
            fi

            if [[ -d "${name}" ]]; then
                rm -r "${name}"
            fi

            continue

        elif [[ "${curr_type}" == "file" ]]; then

            if [[ "${permissions}" == "nonexistant" ]]; then
                if [[ -f "${name}" ]]; then
                    rm "${name}"
                fi
                continue
            fi

            directory=$(dirname "${name}")

            if [[ ! -d "${directory}" ]]; then
                mkdir -p "${directory}" -m="${permissions}"
            fi

            touch "${name}"
            chmod "${permissions}" "${name}"
            continue

        elif [[ "${curr_type}" == "symlink" ]]; then

            if [[ ! -e "${permissions}" ]]; then
                directory=$(sed -E "s/^([[:alnum:]][/])+${name}$/\1/")

                if [[ ! -d "${directory}" ]]; then
                    mkdir -p "${directory}" -m="${permissions}"
                fi

                touch "${permissions}"
            fi

            ln -s "${permissions}" "${name}"
            continue

        elif [[ "${permissions}" != "nonexistant" ]]; then
            echo "Invalid input!"
            continue
        else
            echo "Does not exist!"
            continue
        fi
    fi

    # existing!
    if stat "${name}" -c '%F' | grep -q "${curr_type}"; then
        # upload metadata
        #chown "${user_owner}":"${group_owner}" "${name}"
        chmod "${permissions}" "${name}"
        continue
    fi

done < <(cat "${1}")
