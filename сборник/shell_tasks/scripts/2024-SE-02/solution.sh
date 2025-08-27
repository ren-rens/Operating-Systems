#!/bin/bash

local_users_file="/etc/passwd"

if env | grep -q "${PASSWD}"; then
    local_users_file=$(echo "${PASSWD}")
fi

script_path=$(dirname "${BASH_SOURCE[0]}")
occ="${script_path}/occ"

if [[ ! -x "${occ}" ]]; then
    echo "Program does not exist or is not executable!"
    exit 1
fi

local_users=$(awk -F ':' ' $3 >= 1000 { print $1 } ' "${local_users_file}")
cloud_users=$("${occ}" user:list | sed -E 's/^- ([^:]+):.*/\1/')

for local_user in "${local_users}"; do
    found=0
    for cloud_user in "${cloud_users}"; do
        if [[ "${local_user}" == "${cloud_user}" ]]; then
            found=1
            break
        fi
    done

    if [[ "${found}" == 1 ]]; then
        "${occ}" user:add "${local_user}"
        continue
    fi

    enabled=$("${occ}" user:info "${local_user}" | grep -E "^- enabled:" | awk '{ print $3 }')
    if [[ "${enabled}" == "false" ]]; then
        "${occ}" user:enable "${local_user}"
    fi
done

for cloud_user in "${cloud_users}"; do
    found=0
    for local_user in "${local_users}"; do
        if [[ "${cloud_user}" == "${local_user}" ]]; then
            found=1
            break
        fi
    done

    if [[ "${found}" -eq 1 ]]; then
        enabled=$("${occ}" user:info "$cloud_user" | grep '^- enabled:' | awk '{print $3}')
        if [[ "$enabled" == "true" ]]; then
            "${occ}" user:disable "$cloud_user"
        fi
    fi
done
