#!/bin/bash

last_arg_jar=0
last_arg_filename=0
options=$(mktemp)
args=$(mktemp)
filename=""
valid=0

for i in "${@}"; do
    if [[ "${i}" == "java" ]]; then
        valid=1
        continue
    fi

    if [[ "${i}" == "-jar" ]]; then
        last_arg_jar=1
        last_arg_filename=0
        continue
    fi

    if [[ "${last_arg_jar}" -eq 0 ]] && [[ "${last_arg_filename}" -eq 0 ]]; then
        if [[ "${i}" =~ D(.*)=(.+) ]]; then
            # options
            echo "${i}" >> "${options}"
        else
            # invalid placement
            def=$(echo "${i}" | cut -d '=' -f 1)
            echo "${def}=default" >> "${options}"
        fi
    fi

    # filename after -jar
    if [[ "${last_arg_jar}" -eq 1 ]]; then
        filename="${i}"
        last_arg_filename=1
        last_arg_jar=0
        continue
    elif [[ "${last_arg_filename}" -eq 1 ]]; then
        # args
        echo "${i}" >> "${args}"
        continue
    fi
done

opts=$(cat "${options}" | tr '\n' ' ')
arguments=$(cat "${args}" | tr '\n' ' ')

rm "${options}"
rm "${args}"

if [[ "${valid}" -eq 1 ]]; then
    # can be executed
    echo "Executing java program"
    echo "java ${opts}-jar ${filename} ${arguments}"
else
    echo "Cannot execute java program"
fi
