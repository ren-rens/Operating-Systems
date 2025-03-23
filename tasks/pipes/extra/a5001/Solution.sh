cat /etc/passwd | cut -d ':' -f 7 | grep -v /bin/bash | wc -l
