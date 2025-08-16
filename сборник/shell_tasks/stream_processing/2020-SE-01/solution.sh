#!/bin/bash
find "${HOME}" -type f -perm 0022  -exec chmod g+w {} \;
