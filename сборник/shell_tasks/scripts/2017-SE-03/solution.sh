#!/bin/bash

# if [[ "$(whoami)" != "root" ]]; then
#     echo "Script must be started from a root!"
#     exit 1
# fi

proccesses=$(ps -e -o uid=,pid=,rss=)

result=$(mktemp)

while read user; do
    count=0
    rss=0
    max_rss=0

    while read proccess; do
        curr_rss=$(echo "${proccess}" | awk '{ print $3 }')

        count=$((count+1))

        rss=$(echo "${rss} + ${curr_rss}" | bc)

        if [[ "${curr_rss}" -gt "${max_rss}" ]]; then
            max_rss="${curr_rss}"
        fi

    done < <(echo "${proccesses}" | grep "${user}")

    echo "${user} ${count} ${rss}" >> "${result}"

    if [[ "${count}" -gt 0 ]]; then
        average=$(echo "${rss}/${count}" | bc)

        if (( $(echo "${max_rss} > 2 * ${average}" | bc -l) )); then
            pid=$(echo "${proccesses}" | grep "${user} [1-9]+[0-9]* ${max_rss}")

            # kill ${pid}

            echo "${pid}"
        fi
    fi

done < <(echo "${proccesses}" | awk '{ print $1 }' | sort | uniq)

cat "${result}"

rm "${result}"
