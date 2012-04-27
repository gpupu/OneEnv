#!/bin/bash

#echo "esto es una prueba" >> /home/nebulito/prueba
#echo "Instalando gedit"
#apt-get -y install vim
#echo "Instalando vim"
#sudo apt-get -y install vim

mount -t iso9660 /dev/vdc /mnt

. ./mnt/chef.sh >/var/log/cheflog 2>&1

umount /mnt

exit 0
