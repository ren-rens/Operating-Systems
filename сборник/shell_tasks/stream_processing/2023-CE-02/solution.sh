#!/bin/bash

count=0
while read file; do
  if cat "${file}" | grep -q "error"; then
    count=$((count + 1))
  fi
done< <(find /var/log/my_logs -type f -name "[[:alnum:]_]*_[0-9]+\.log")

echo "count of log file with word error: ${count}\n"
