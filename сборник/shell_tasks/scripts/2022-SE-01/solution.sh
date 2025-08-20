#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "Two arguments needed!"
    exit 1
fi

if [[ ! -f "$1" ]] || [[ ! -f "$2" ]]; then
    echo "Arguments must be files!"
    exit 2
fi

while read line; do
    if [[ "$line" =~ ^#.* ]]; then
        continue
    fi

    device=$(echo "$line" | awk '{print $1}')

    if ! grep -q "$device" "$2"; then
        echo "No such device in the file!"
        continue
    fi

    wanted_status=$(echo "$line" | awk '{print $2}')
    curr_status=$(grep "$device" "$2" | awk '{print $3}' | tr -d '*')

    if [[ "$curr_status" == "$wanted_status" ]]; then
        continue
    fi

    sed -E -i "s/${device}(.*)${curr_status}/${device}\1${wanted_status}/" "$2"
done < "$1"
