 #!/bin/bash
#name;type;avg_distance;mass;volume;density;avg_orbital_velocity

farest_object=$(cat "planets.txt" | tail -n +2 | sort -rn -t ';' -k 3 | head
echo "${farest_object}"

while read line; do
  curr_type=$(echo "${line}" | awk -F ';' ' { print $2 } ')
  if [[ "${curr_type}" == "${farest_object}" ]]; then
    name=$(echo "${line}" | awk -F ';' ' { print $1} ')
    masss=$(echo "${line}" | awk -F ';' ' {print $4} ')
    echo "${name}   ${mass}"
    exit 0
 fi
done< <(cat "planets.txt" | tail -n +2 | sort -t ';' -k 3)
 
echo "NO SUCH OBJECT"
