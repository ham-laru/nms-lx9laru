#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Send a SNMP command to reboot the hytera repeater remotely."
  echo "Usage: $0 <IP_ADDRESS>"
  echo "Example: $0 192.168.1.1"
  exit 1
fi

snmpset -v1 -c public $1  .1.3.6.1.4.1.40297.1.2.2.1.0 i 1
