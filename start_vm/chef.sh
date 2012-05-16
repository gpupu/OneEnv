#!/bin/bash

readonly DISK="/mnt/"
readonly CBDISK="${DISK}/cookbooks/"
readonly RDISK="${DISK}/roles/"
readonly DBDISK="${DISK}${CHEF_DATABAGS}/"

# CHEF_DIR se carga en el context
readonly CBPATH="${CHEF_DIR}/cookbooks/"
readonly RPATH="${CHEF_DIR}/roles/"
readonly DBPATH="${CHEF_DIR}/data_bags/"

readonly JPATH="${CHEF_DIR}/${CHEF_NODE}"
readonly CPATH="${CHEF_DIR}/config.rb"

# Crea el directorio (no hace nada si ya existe)
mkdir -vp $CHEF_DIR


# Crea el archivo solo.rb
echo "Creando archivo configuracion"
echo "file_cache_path \"${CHEF_DIR}\"" > $CPATH
echo "cookbook_path \"${CBPATH}\"" >> $CPATH
echo "role_path \"${RPATH}\"" >> $CPATH
echo "data_bag_path \"${DBPATH}\"" >> $CPATH


# Copia todo al disco
echo "copiando elementos al disco"
# Copia Cookbooks
if [ $CHEFCB='' ]; then
	#oIFS=$IFS
	mkdir -v $CBPATH
	export IFS=";"

	for cookbook in $CHEFCB 
	do
		cp -rv "${DISK}/$cookbook" "${CBPATH}/$cookbook"
	done
	unset IFS
	#IFS=$oIFS

else
	cp -rv $CBDISK $CBPATH
fi


# Copia Roles
if [ $CHEFR='' ]; then
	mkdir -v $RPATH
	export IFS=";"

	for role in $CHEFR 
	do
		cp -rv "${DISK}/$role" "${RPATH}/$role"
	done
	unset IFS

else
	cp -rv $CBDISK $CBPATH
fi

# Copia Databags
if [ -d $DBDISK ]; then
	cp -rv $DBDISK $DBPATH
fi

# Copia node
cp -rv $DISK/$CHEF_NODE $CHEF_DIR

# Ejecuta Chef-solo
echo "Ejecuta chef-solo"
chef-solo -c $CPATH -j $JPATH
