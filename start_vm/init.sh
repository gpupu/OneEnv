#!/bin/bash



if [ -f /mnt/context.sh ]; then
	echo "Ejecutando Context"
	. /mnt/context.sh  > /var/log/context 2>&1
fi


if [ -f /mnt/chef.sh ]; then
echo "Ejecutando Chef..."
	. /mnt/chef.sh > /var/log/cheflog 2>&1
fi






