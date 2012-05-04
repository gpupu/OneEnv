#!/bin/bash

echo "Ejecutando Bootstrap..."
. /mnt/bootstrap.sh >/var/log/cheflog 2>&1

echo "Ejecutando Chef..."
. /mnt/chef.sh >>/var/log/cheflog 2>&1




