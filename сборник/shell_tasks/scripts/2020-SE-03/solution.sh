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
package_name=$(basename "${package}")

if [[ ! -f "${package}/version" ]]; then
    echo "Package must have a version file!"
    exit 3
fi

if [[ ! -d "${package}/tree" ]]; then
    echo "Package must have a tree directory!"
    exit 4
fi

archive="${package_name}.tar.xz"
tar -caf "${archive}" "${package}/tree"

checksum=$(sha256sum "${archive}" | awk ' { print $1 } ')

version=$(cat "${package}/version")

if grep -qE "^${package_name}-${version}" "${repo}/db"; then
    echo "Got ${package}-${version}"

    sum=$(grep -E "^${package_name}-${version}" "${repo}/db" | cut -d ' ' -f 2-)
    sed -iE "s/^${package_name}-${version} ${sum}$/${package_name}-${version} ${checksum}/" "${repo}/db"

    if [[ -f "${repo}/packages/${sum}.tar.xz" ]]; then
        rm "${repo}/packages/${sum}.tar.xz"
    fi
else
    echo "${package_name}-${version} ${checksum}">> "${repo}/db"
fi

sort -o "${repo}/db" "${repo}/db"

mv "${archive}" "${repo}/packages/${checksum}.tar.xz"
