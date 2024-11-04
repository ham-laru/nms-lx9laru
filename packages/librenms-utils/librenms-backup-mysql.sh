#!/usr/bin/env bash

sudo mysqldump librenms | gzip > "librenms-$(date +'%Y-%m-%d').sql.gz"
