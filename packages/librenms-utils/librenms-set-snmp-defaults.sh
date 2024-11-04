#!/usr/bin/env bash

echo "This will set the default SNMP settings for librenms."
read -p "Enter the snmp password: " password

librenms-artisan config:set snmp.v3.0 '{
    "authlevel": "authNoPriv",
    "authname": "lx9laru-nms",
    "authpass": '"\"${password}\""',
    "authalgo": "SHA",
    "cryptopass": "",
    "cryptoalgo": "AES"
}'


