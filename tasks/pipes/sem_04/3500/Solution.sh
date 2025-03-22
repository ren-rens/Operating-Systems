cat /etc/passwd | grep -A 2 "$(whoami)"

cat /etc/passwd | grep -B 2 "$(whoami)" | head -n 1
