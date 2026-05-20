#!/bin/sh
set -e
chown -R proxy:proxy /var/log/squid
exec "$@"
