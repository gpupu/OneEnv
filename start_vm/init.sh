#!/bin/bash



if [ -f /mnt/context.sh ]; then
	echo "Ejecutando Context"
	. /mnt/context.sh  > /var/log/context 2>&1
fi

echo "BOOTSTRAP "$CHEF_BOOTSTRAP

if [ -f /mnt/$CHEF_BOOTSTRAP ]; then
	echo "Ejecutando Bootstrap..."
	. /mnt/$CHEF_BOOTSTRAP 
fi

if [ -f /mnt/chef.sh ]; then
echo "Ejecutando Chef..."
	. /mnt/chef.sh >>/var/log/cheflog 2>&1
fi






