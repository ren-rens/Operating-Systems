#!/bin/bash
  
if [[ $# -ne 1 ]]; then
     echo "one param needed!"
     exit 1
fi
  

if [[ ! -d "${1}" ]]; then
     echo "param must be a directory"
     exit 2
fi
 
while read link; do
    if [[ ! -f $(readlink -q "${link}") ]]; then
    echo "${link}"
    fi
done< <(find "${1}" -type l)
