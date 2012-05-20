#!/bin/bash

readonly DISK="/mnt/"
readonly CBDISK="${DISK}/cookbooks/"
readonly RDISK="${DISK}/roles/"
readonly DBDISK="${DISK}/${CHEF_DATABAGS}/"

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
if [ -n "${CHEFCB}" ]; then
	echo "copiando cookbooks ${CHEFCB} MODO DEPS"
	mkdir -v $CBPATH
	oIFS=$IFS
	IFS=";"	
	for cookbook in $CHEFCB 
	do
		cp -rv "${DISK}/$cookbook" "${CBPATH}/$cookbook"
	done
	IFS=$oIFS

else
	echo "copiando cookbooks a ${CBPATH}"
	cp -rv $CBDISK $CHEF_DIR
fi


# Copia Roles
if [ -n "${CHEFR}" ]; then
	mkdir -v $RPATH
	echo "copiando roles a ${CHEFR} MODO DEPS"
	oIFS=$IFS
	IFS=";"
	for role in $CHEFR 
	do
		cp -rv "${DISK}/$role" "${RPATH}/$role"
	done
	IFS=$oIFS

else
	echo "copiando roles a ${RPATH}"
	cp -rv $CBDISK $CHEF_DIR
fi

# Copia Databags
if [ -n "${CHEF_DATABAGS}" ]; then
	echo "copiando databags a ${DBPATH}"
	cp -rv $DBDISK $DBPATH
fi

# Copia node
cp -rv $DISK/$CHEF_NODE $CHEF_DIR

# Ejecuta Chef-solo
echo "Ejecuta chef-solo"
chef-solo -c $CPATH -j $JPATH
