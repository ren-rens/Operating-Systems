#!/bin/bash

if [[  "${USER}" != "oracle" ]] && [[ "${USER}" != "grid" ]]; then
  echo "User must be oracle or grid"
  exit 1
fi

if [[ $# -ne 1 ]]; then
  echo "One argument needed!"
  exit 2
fi

if [[ ! "${1}" =~ ^[1-9]+[0-9]*$|^0$ ]] || [[ "${1}" -gt 2 ]]; then
  echo "Argument must be a number less than 2!"
  exit 3
fi

dir="u01/app/${USER}"
if [[ ! -d "${dir}" ]]; then
  echo "No home directory for the user exists!"
  exit 4
fi

if env | grep -qE "${ORACLE_HOME}"; then
  echo "No env oracle home exists!"
  exit 5
fi

if [[ ! -f $(find "${ORACLE_HOME}" - type f | grep "bin/adrci") ]]; then
  echo "NO file adrci in /bin directry exists!"
  exit 6
fi

dir_path=$(realpath "${dir}")
adrci="${ORACLE_HOME}/bin/adrci"
cmd1="SET BASE ${dir_path}"

minutes=$(echo "${1} * 60" | bc)

homes=$(mktemp)

"${adrci}" exec="${cmd1}; SHOW HOMES" | grep -E "crs|tnslsnr|kfod|asm|rdbms" >> "${homes}"

while read home; do
  "${adrci}" exec="${cmd1}; SET HOMEPATH ${home}; PURGE -AGE ${minutes}"
done< <(cat "${homes} | sort)

rm "${homes}"
