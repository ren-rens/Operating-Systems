#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "Two arguments needed!"
    exit 1
fi

if [[ ! -f "${1}" ]]; then
    echo "First argument must be a file!"
    exit 2
fi

if [[ ! -d "${2}" ]]; then
    echo "Second argument must be a directory!"
    exit 3
fi

echo "hostname,phy,vlans,hosts,failover,VPN-3DES-AES,peers,VLAN Trunk Ports,license,SN,key" >> "${1}"

while read file; do
    # read the file and create the row in csv file
    hostname=$(echo "${file}" | awk -F '/' ' { print $NF } ' | cut -d '.' -f 1)
    phy=$(cat "${file}" | grep "Maximum Physical Interfaces" | awk ' { print $5 } ')
    vlans=$(cat "${file}" | grep "VLANs" | awk ' { print $3 } ')
    hosts=$(cat "${file}" | grep "Hosts" | awk ' { print $4 } ')
    failover=$(cat "${file}" | grep "Failover" | awk ' { print $3 }')
    VPN_3DES_AES=$(cat "${file}" | grep "VPN-3DES-AES" | awk ' { print $3 } ')
    peers=$(cat "${file}" | grep "Peers" | awk ' { print $5} ')
    VLAN_Trunk_Ports=$(cat "${file}" | grep "Ports" | awk ' { print $5 } ')
    license=$(cat "${file}" | grep "license" | cut -d ' ' -f 5- | sed 's/ license.//')
    SN=$(cat "${file}" | grep "Serial Number" | cut -d ' ' -f 3-)
    key=$(cat "${file}" | grep "Key" | cut -d ' ' -f 4)

    echo "${hostname},${phy},${vlans},${hosts},${failover},${VPN_3DES_AES},${peers},${VLAN_Trunk_Ports},${license},${SN},${key}" >> "${1}"
done< <(find "${2}" -type f -name "*\.log")
