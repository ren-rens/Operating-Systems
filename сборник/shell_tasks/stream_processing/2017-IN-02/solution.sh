#!/bin/bash

find . -type f -size 0 -exec rm {} \;
find "$HOME" -type f -printf '%s %p\n' |sort -nr | head -n 5 | awk '{print $2}' | xargs rm -f
