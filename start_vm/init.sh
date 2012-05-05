#!/bin/bash

echo "Ejecutando Context"
. /mnt/context.sh >/var/log/cheflog 2>&1

if [ -f /mnt/bootstrap.sh ]; then
	echo "Ejecutando Bootstrap..."
	. /mnt/bootstrap.sh >>/var/log/cheflog 2>&1
fi

echo "Ejecutando Chef..."
. /mnt/chef.sh >>/var/log/cheflog 2>&1




