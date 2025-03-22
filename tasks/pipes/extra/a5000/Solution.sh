cat /etc/passwd | grep "$(cat /etc/passwd | cut -d ':' -f 1 | whoami)"
