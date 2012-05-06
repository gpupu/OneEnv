#!/bin/bash

readonly DISK="/mnt/"
readonly CBDISK="${DISK}cookbooks/"
readonly RDISK="${DISK}roles/"
readonly DBDISK="${DISK}${CHEF_DATABAGS}/"

readonly CHPATH="/tmp/chef/"
readonly CBPATH="${CHPATH}cookbooks/"
readonly RPATH="${CHPATH}roles/"
readonly DBPATH="${CHPATH}data_bags"

readonly JPATH="${CHPATH}node.json"
readonly CPATH="${CHPATH}config.rb"

# Crea el directorio
mkdir -v $CHPATH


# Crea el archivo solo.rb
echo "Creando archivo configuracion"
echo "file_cache_path \"${CHPATH}\"" > $CPATH
echo "cookbook_path \"${CBPATH}\"" >> $CPATH
echo "role_path \"${RPATH}\"" >> $CPATH
echo "data_bag_path \"${DBPATH}\"" >> $CPATH


# Copia todo al disco
echo "copiando elementos al disco"
cp -rv $CBDISK $CBPATH
cp -rv $RDISK $RPATH
if [ -d $DBDISK ]; then
	cp -rv $DBDISK $DBPATH
fi

cp -rv $DISK/$CHEF_NODE $CHPATH

# Ejecuta Chef-solo
echo "Ejecuta chef-solo"
chef-solo -c $CPATH -j $JPATH
