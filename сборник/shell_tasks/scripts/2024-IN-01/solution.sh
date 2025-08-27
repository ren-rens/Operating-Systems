#!/bin/bash

if [[ "${#}" -lt 1 ]]; then
    echo "At least one argument needed!"
    exit 1
fi

if ! echo "${@}" | grep -Eq "pull|push"; then
    echo "PUSH or PULL needed!"
    exit 2
fi

if echo "${@}" | grep -Eq "push" && echo "${@}" | grep -E "pull"; then
    echo "push OR pull needed! not BOTH!"
    exit 3
fi

if ! env | grep -q "ARKCONF"; then
    echo "NO FILE"
    exit 4
else
    file=$(echo "${ARKCONF}")
    dir=$(cat "${file}" | grep "WHAT=" | cut -d '=' -f 2 | tr -d "\"")
    SERVER_SPECIFIED=$(cat "${file}" | grep "WHERE=" | cut -d '=' -f 2 | tr -d "\"")
    username=$(cat "${file}" | grep "WHO=" | cut -d '=' -f 2 | tr -d "\"")

    if [[ "${dir}" == "" ]] || [[ "${servers}" == "" ]] || [[ "${username}" == "" ]]; then
        echo "NOT defiend data!"
        exit 5
    fi
fi

if echo "${@}" | grep -Eq "push"; then
    COMMAND="push"
    shift
else
    COMMAND="pull"
    shift
fi

if echo "${@}" | grep -q "[-d]"; then
    DELETE_FLAG="--delete"
    shift
else
    DELETE_FLAG=""
fi

SERVERS=${SERVER_SPECIFIED}
if [[ "$1" =~ ^[a-z]+$ ]]; then
    SERVER_SPECIFIED="$1"
fi

SRC_DIR="$dir/"
DEST_DIR="$dir/"

echo "We will sync: $SRC_DIR"
echo "With the servers: $SERVERS"
if [ "$COMMAND" == "push" ]; then
  echo "Sync from local machines to serves."
else
  echo "From servers to local machines."
fi

read -p "Do you want to continue? (y/n): " confirmation
if [ "$confirmation" != "y" ]; then
  echo "Cancelled sync."
  exit 0
fi

for SERVER in $SERVERS; do
  if [ "$COMMAND" == "push" ]; then
    echo "From local machine to $SERVER..."
    rsync -av $DELETE_FLAG "$SRC_DIR" "$username@$SERVER:$DEST_DIR"
  else
    echo "From $SERVER to local machine"
    rsync -av $DELETE_FLAG "$username@$SERVER:$SRC_DIR" "$DEST_DIR"
  fi
done

echo "done"
