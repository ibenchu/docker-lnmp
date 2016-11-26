#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
# or first arg is `something.conf`
if [ "${1#-}" != "$1" ] || [ "${1%.conf}" != "$1" ]; then
	set -- redis-server "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'redis-server' -a "$(id -u)" = '0' ]; then
	chown -R redis .
	exec su-exec redis "$0" "$@"
fi

echo "vm.overcommit_memory=1" > /etc/sysctl.conf
echo 1 > /proc/sys/vm/overcommit_memory
echo 511 > /proc/sys/net/core/somaxconn

exec "$@"
