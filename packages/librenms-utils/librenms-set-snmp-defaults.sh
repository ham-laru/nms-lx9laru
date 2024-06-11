#!/usr/bin/env bash

read -p "Enter the snmp password: " password

librenms-artisan config:set snmp.v3.0 '{
    "authlevel": "authNoPriv",
    "authname": "lx9laru-nms",
    "authpass": '"\"${password}\""',
    "authalgo": "SHA",
    "cryptopass": "",
    "cryptoalgo": "AES"
}'


