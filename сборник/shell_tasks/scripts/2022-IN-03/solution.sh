#!/bin/bash

last_arg_jar=0
options=$(mktemp)
args=$(mktemp)
filename=""
valid=0

for i in "$@"; do
    if [[ "$i" == "java" ]]; then
        valid=1
        continue
    fi

    if [[ "$i" == "-jar" ]]; then
        last_arg_jar=1
        continue
    fi

    if [[ $last_arg_jar -eq 1 ]]; then
        if [[ "$i" == *.jar ]]; then
            filename="$i"
            last_arg_jar=0
        fi
        continue
    fi

    if [[ -n "$filename" ]]; then
        echo "$i" >> "$args"
    else
        if [[ "$i" =~ ^-D[^=]+=.+$ ]]; then
            # valid option -D
            echo "$i" >> "$options"
        else
            # invalid option → property=default
            def=$(echo "$i" | cut -d '=' -f 1)
            echo "-D${def}=default" >> "$options"
        fi
    fi
done

opts=$(tr '\n' ' ' < "$options")
arguments=$(tr '\n' ' ' < "$args")

rm "$options" "$args"

if [[ $valid -eq 1 && -n "$filename" ]]; then
    echo "Executing java program"
    echo "java ${opts}-jar ${filename} ${arguments}"
    exec java ${opts}-jar "$filename" $arguments
else
    echo "Cannot execute java program"
    exit 1
fi
