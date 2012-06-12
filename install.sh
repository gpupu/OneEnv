#! /bin/bash


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


if [ -z "$ONE_LOCATION" ] ; then
    echo "Installing system wide..."
    ONE_BIN_DIR="/usr/bin"
    ONE_LIB_DIR="/usr/lib/one"
    ONE_ETC_DIR="/etc/one"
    ONE_VAR_DIR="/var/lib/one"
else
    echo "Installing self-contained"
    ONE_BIN_DIR=$ONE_LOCATION/bin
    ONE_LIB_DIR=$ONE_LOCATION/lib
    ONE_ETC_DIR=$ONE_LOCATION/etc
    ONE_VAR_DIR=$ONE_LOCATION/var
fi

#LOCATIONS
ONE_LIB_DIR_CLI=$ONE_LIB_DIR/ruby/cli
ONE_LIB_DIR_ONEENV=$ONE_LIB_DIR/ruby/oneenv
ONE_LIB_DIR_START_ENV=$ONE_LIB_DIR/sh/start_env

ONE_VAR_DIR_CHEF_FILES=$ONE_VAR_DIR/chef_files
CHEF_FILES_CBS=$ONE_VAR_DIR_CHEF_FILES/cookbooks
CHEF_FILES_ROLES=$ONE_VAR_DIR_CHEF_FILES/roles

cp -v bin/* $ONE_BIN_DIR
#cp -v etc/* $ONE_ETC_DIR

#generate oneenv.conf
[[ -d $CHEF_FILES_CBS ]] || mkdir -p $CHEF_FILES_CBS
echo "default_cb_dir: ${CHEF_FILES_CBS}" > $ONE_ETC_DIR/oneenv.conf
[[ -d $CHEF_FILES_ROLES ]] || mkdir -p $CHEF_FILES_ROLES
echo "default_role_dir: ${CHEF_FILES_ROLES}" >> $ONE_ETC_DIR/oneenv.conf
echo "default_solo_path: /tmp/chef" >> $ONE_ETC_DIR/oneenv.conf

[[ -d $ONE_LIB_DIR_CLI ]] || mkdir -p $ONE_LIB_DIR_CLI
cp -Rv lib/cli/* $ONE_LIB_DIR_CLI
[[ -d $ONE_LIB_DIR_ONEENV ]] || mkdir -p $ONE_LIB_DIR_ONEENV
cp -v lib/oneenv/* $ONE_LIB_DIR_ONEENV
[[ -d $ONE_LIB_DIR_START_ENV ]] || mkdir -p $ONE_LIB_DIR_START_ENV
cp -v lib/start_env/* $ONE_LIB_DIR_START_ENV

echo "Installation completed successfully!"
