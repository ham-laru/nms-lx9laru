#!/usr/bin/env bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Configures the hytera repeater to send traps to the NMS station."
  echo "Usage: $0 <IP_OF_HYTERA> <IP_OF_NMS>" 
  echo "Example: $0 192.168.1.1 192.168.1.200"
  exit 1
fi

snmpset -v1 -c public $1 .1.3.6.1.4.1.40297.1.2.2.8.0 a $2
