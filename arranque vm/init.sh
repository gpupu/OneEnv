#!/bin/bash

mount -t iso9660 /dev/vdc /mnt

. ./mnt/chef.sh >/var/log/cheflog 2>&1

umount /mnt

exit 0
