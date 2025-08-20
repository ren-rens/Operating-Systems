#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "One argument needed!"
    exit 1
fi

dir="$1"
if [[ ! -d "$dir" ]]; then
    echo "Argument must be a directory!"
    exit 2
fi

tmpfile=$(mktemp)

while read -r file; do
    sum=$(sha256sum "$file" | awk '{print $1}')
    links=$(stat -c %h "$file")
    echo "$sum $links $file" >> "$tmpfile"
done < <(find "$dir" -type f)

sort "$tmpfile" -o "$tmpfile"

last_sum=""
first_single=""
first_link=""
single_count=0
link_count=0

while IFS= read -r line; do
    sum=$(echo "$line" | cut -d' ' -f1)
    links=$(echo "$line" | cut -d' ' -f2)
    file=$(echo "$line" | cut -d' ' -f3-)

    if [[ "$sum" != "$last_sum" && "$last_sum" != "" ]]; then
        first_single=""
        first_link=""
        single_count=0
        link_count=0
    fi

    if [[ "$links" -eq 1 ]]; then
        single_count=$((single_count+1))
        if [[ -z "$first_single" ]]; then
            first_single="$file"
        else
            echo "$file"
        fi
    else
        link_count=$((link_count+1))
        if [[ -z "$first_link" ]]; then
            first_link="$file"
        else
            echo "$file"
        fi
    fi

    last_sum="$sum"

done < "$tmpfile"

rm "$tmpfile"
