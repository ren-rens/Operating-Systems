cat /etc/passwd | cut -d ':' -f 5 | cut -d ',' -f 1 | sort | uniq > users.txt
