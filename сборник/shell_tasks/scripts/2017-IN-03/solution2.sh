#!/bin/bash

home_dirs=$(mktemp)

# Записваме всички home директории от /etc/passwd във временен файл
cut -d ':' -f 6 /etc/passwd > "${home_dirs}"

first_dir="${HOME}"
latest_timestamp=0
modified_file=""
modified_time=""
modified_user=""

while read line; do
    # Пропускаме невалидни директории
    if [[ ! -d "${line}" || ! -r "${line}" ]]; then
        continue
    fi

    # Търсим най-новия файл (коригирана команда find)
    newest_file=$(find "${line}" -type f -printf "%T@ %p\n" 2>/dev/null | sort -n | tail -n 1)

    if [[ -n "$newest_file" ]]; then
        file_timestamp=$(echo "$newest_file" | awk '{print $1}')
        file_path=$(echo "$newest_file" | awk '{print $2}')

        # Сравняваме времената (коригирано сравнение)
        if (( $(echo "$file_timestamp > $latest_timestamp" | bc -l) )); then
            latest_timestamp=$file_timestamp
            modified_time=$(date -d "@$file_timestamp" "+%Y-%m-%d %H:%M:%S")
            modified_user=$(grep "${line}" /etc/passwd | cut -d ':' -f 1)
            modified_file="${file_path}"
        fi
    fi
done < "${home_dirs}"

# Извеждаме резултатите
if [[ -n "$modified_file" ]]; then
    echo "Потребител: $modified_user"
    echo "Файл: $modified_file"
    echo "Последна промяна: $modified_time"
else
    echo "Не беше намерен нито един файл в home директориите"
fi

rm "${home_dirs}"
