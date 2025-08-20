#!/bin/bash

commands=$(mktemp)
count=0
max_memory=65536

while true; do
    curr_comms=$(mktemp)

    ps -e -o comm=,rss= | sort > "$curr_comms"

    over_limit=0
    last_comm=""
    sum=0

    while read comm rss; do
        if [[ "$comm" == "$last_comm" ]]; then
            sum=$((sum + rss))
        else
            if [[ -n "$last_comm" && $sum -ge $max_memory ]]; then
                echo "$last_comm" >> "$commands"
                over_limit=1
            fi
            last_comm="$comm"
            sum=$rss
        fi
    done < "$curr_comms"

    if [[ -n "$last_comm" && $sum -ge $max_memory ]]; then
        echo "$last_comm" >> "$commands"
        over_limit=1
    fi

    rm "$curr_comms"

    if [[ $over_limit -eq 0 ]]; then
        break
    fi

    sleep 1
    count=$((count + 1))
done

half_count=$((count / 2))

sort "$commands" | uniq -c | while read occur comm; do
    if [[ $occur -ge $half_count ]]; then
        echo "$comm"
    fi
done

rm "$commands"
