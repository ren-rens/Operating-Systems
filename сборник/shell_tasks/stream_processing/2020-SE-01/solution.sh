#!/bin/bash
find "${HOME}" -type f -perm 0644  -exec chmod g+w {} \;
