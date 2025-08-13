cat /etc/passwd | grep 'SI' | cut -d ':' -f 1-5 | cut -d ',' -f 1 | grep -E 'а$' | cut -d ':' -f 1 | tr -d 's' | sed -E 's/[0-9]([0-9]{2}).*/\1/g' | sort | uniq -c | sort -nr | head -n 1
