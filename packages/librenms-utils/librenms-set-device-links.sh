#!/usr/bin/env bash

# Sets device links for LibreNMS devices that point to Mikrotik WebFig

librenms-artisan config:set html.device.links.0 '{"url": "https://{{$device->ip}}:15733", "title": "WebFig"}'
