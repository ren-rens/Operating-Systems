#!/bin/bash

if [[ ! -f "spacex.txt" ]]; then
  echo "no spacex.txt file exists!"
  exit 1
fi

failures=$(cat "spacex.txt" | tail -n +2 | grep "Failure" | cut -d '|' -f 2 | sort | uniq -c | sort -rn | head -n 1 | awk ' { print $2 } ')
grep "${failures}" "spacex.txt" | sort -rn -t '|' -k 1 | head -n 1 | cut -d '|' -f 3-4

exit 0
