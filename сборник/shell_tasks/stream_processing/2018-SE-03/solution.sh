cat /etc/passwd| sort -t ':' -k 1 | grep 'SI' | cut -d ':' -f 5-6 | tr -d 'S
