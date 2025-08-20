#!/bin/bash

if [[ $# -lt 2 ]]; then
    echo "At least 2 arguments needed!"
    exit 1
fi

if ! [[ "$1" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo "First argument must be a number!"
    exit 2
fi

duration="$1"
shift

count=0
total=0

start_time=$(date +%s.%N)

while true; do
    cmd_start=$(date +%s.%N)
    "$@"
    cmd_end=$(date +%s.%N)

    runtime=$(echo "$cmd_end - $cmd_start" | bc -l)
    total=$(echo "$total + $runtime" | bc -l)
    count=$((count + 1))

    now=$(date +%s.%N)
    elapsed=$(echo "$now - $start_time" | bc -l)

    if (( $(echo "$elapsed >= $duration" | bc -l) )); then
        break
    fi
done

avg=$(echo "scale=2; $total / $count" | bc)
echo "Ran the command '$*' $count times for $(printf "%.2f" "$elapsed") seconds."
echo "Average runtime: $(printf "%.2f" "$avg") seconds."
