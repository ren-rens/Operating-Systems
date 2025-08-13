find / -type f -links +1 -user "$USER" -printf '%T@ %i\n' 2>/dev/null | sort -nr | head -n 1 | awk ' { print $2 } '
