find /home/students/s0600336 -maxdepth 1 -type f -user $(whoami) 2>/dev/null -exec chmod o+r {} \;
