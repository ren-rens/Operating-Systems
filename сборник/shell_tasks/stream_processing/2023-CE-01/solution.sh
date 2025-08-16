find "${HOME}" -maxdepth 1 -mindepth 1 -type f -user "${USER}" 2>/dev/null -exec chmod 0002 {} \;
