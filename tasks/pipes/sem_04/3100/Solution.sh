cat /etc/passwd | cut -d ':' -f 1 | uniq > users.txt
