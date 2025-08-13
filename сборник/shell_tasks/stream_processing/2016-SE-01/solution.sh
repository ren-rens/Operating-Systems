#!/bin/bash

if [[ ! -f "philip-j-fry.txt" ]]; then
  echo "must be a file!"
  exit 1
fi

count=$(grep '[02468]' philip-j-fry.txt | grep -v '[a-w]' | wc -l)
echo "${count}"
