#!/bin/bash

# --------------------------------------------------------------------------#
# Copyright 2012   David Baena, Fernando Martínez-Conde, José Gabriel Puado	#
# 																			#
# Licensed under the Apache License, Version 2.0 (the "License"); you may 	#
# not use this file except in compliance with the License. You may obtain 	#
# a copy of the License at 													#
# 																			#
# http://www.apache.org/licenses/LICENSE-2.0 								#
# 																			#
# Unless required by applicable law or agreed to in writing, software 		#
# distributed under the License is distributed on an "AS IS" BASIS, 		#
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 	#
# See the License for the specific language governing permissions and 		#
# limitations under the License. 											#
#---------------------------------------------------------------------------#

readonly DISK="/mnt"
readonly CBDISK="${DISK}/cookbooks/"
readonly RDISK="${DISK}/roles/"
readonly DBDISK="${DISK}/${CHEF_DATABAGS}/"


# CHEF_DIR in CONTEXT
readonly CBPATH="${CHEF_DIR}/cookbooks/"
readonly RPATH="${CHEF_DIR}/roles/"
readonly DBPATH="${CHEF_DIR}/data_bags/"

readonly JPATH="${CHEF_DIR}/${CHEF_NODE}"
readonly CPATH="${CHEF_DIR}/config.rb"


mkdir -vp $CHEF_DIR

# Config file
echo "Creating Chef's config file"
echo "file_cache_path \"${CHEF_DIR}\"" > $CPATH
echo "cookbook_path \"${CBPATH}\"" >> $CPATH
echo "role_path \"${RPATH}\"" >> $CPATH
echo "data_bag_path \"${DBPATH}\"" >> $CPATH


# copying cookbooks
if [ -n "${CHEFCB}" ]; then
	echo "copying cookbooks ${CHEFCB} MODO DEPS"
	mkdir -v $CBPATH
	oIFS=$IFS
	IFS=";"	
	for cookbook in $CHEFCB 
	do
		cp -rv "${DISK}/$cookbook" "${CBPATH}$cookbook"
	done
	IFS=$oIFS

else
	echo "copying cookbooks to ${CBPATH}"
	cp -rv $CBDISK $CHEF_DIR
fi


# Copia Roles
if [ -n "${CHEFR}" ]; then
	mkdir -v $RPATH
	echo "copying roles to ${CHEFR} MODO DEPS"
	oIFS=$IFS
	IFS=";"
	for role in $CHEFR 
	do
		cp -rv "${DISK}/$role" "${RPATH}$role"
	done
	IFS=$oIFS

else
	if [ -f "${RDISK}" ]; then	
		echo "copying roles to ${RPATH}"
		cp -rv $RDISK $CHEF_DIR
	fi
fi

# Copia Databags
if [ -n "${CHEF_DATABAGS}" ]; then
	echo "copying databags to ${DBPATH}"
	cp -rv $DBDISK $DBPATH
fi

# Copia node
echo "coopyng node"
cp -rv "$DISK/$CHEF_NODE" $CHEF_DIR
# Ejecuta Chef-solo

echo "Chef solo exec"
chef-solo -c $CPATH -j $JPATH


