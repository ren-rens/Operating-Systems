#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "Two arguments needed!"
    exit 1
fi

if [[ ! -d "${1}" ]] || [[ ! -d "${2}" ]]; then
    echo "The arguments must be directories!"
    exit 2
fi

repo="${1}"
package="${2}"

archive="${package}.tar.xz"
tar -caf "${archive}" "${package}"

checksum=$(sha256sum "${archive}" | awk ' { print $1 } ')

version=$(cat "${package}/version")

if grep -qE "^${package}-${version}" "${repo}/db"; then
    echo "Got ${package}-${version}"

    sum=$(grep -E "^${package}-${version}" "${repo}/db" | cut -d ' ' -f 2-)
    sed -iE "s/^${package}-${version} ${sum}$/${package}-${version} ${checksum}/" "${repo}/db"

    rm "${repo}/packages/${sum}.tar.xz"
else
    echo "${package}-${version} ${checksum}">> "${repo}/db"
fi

sort -i "${repo}/db"

mv "${archive}" "${repo}/packages/${checksum}.tar.xz"
