#!/bin/bash

readonly DISK="/mnt/"
readonly CBDISK="${DISK}cookbooks/"
readonly RDISK="${DISK}roles/"
readonly DBDISK="${DISK}data_bags/"

readonly CHPATH="/tmp/chef/"
readonly CBPATH="${CHPATH}cookbooks/"
readonly RPATH="${CHPATH}roles/"
readonly DBPATH="${CHPATH}data_bags/"

readonly JPATH="${CHPATH}node.json"
readonly CPATH="${CHPATH}config.rb"

# Crea el directorio
mkdir -pv $CHPATH


# Crea el archivo json
#echo "{\"run_list\": [\"recipe[emacs]\"]}" > /etc/chef/node.json
#echo -n "{\"run_list\": [\"recipe[" > $JPATH
#echo -n $CHEF_RECIPE >> $JPATH
#echo "]\"]}" >> $JPATH


# Crea el archivo solo.rb
echo "creando archivo configuracion"
echo "file_cache_path \"${CHPATH}\"" > $CPATH
echo "cookbook_path \"${CBPATH}\"" >> $CPATH
echo "role_path \"${RPATH}\"" >> $CPATH
echo "data_bag_path \"${DBPATH}\"" >> $CPATH


# Copia todo al disco
echo "copiando elementos al disco"
cp -rv $CBDISK $CBPATH
cp -rv $RDISK $RPATH
cp -rv $DBDISK $DBPATH

cp -rv $DISK/node.json $CHPATH

# Ejecuta Chef-solo
echo "Ejecuta chef-solo"
chef-solo -c $CPATH -j $JPATH
