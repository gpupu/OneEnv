#!/bin/bash

readonly CHPATH="/tmp/chef/"
readonly JPATH="/tmp/chef/node.json"
readonly CPATH="/tmp/chef/solo.rb"

# Crea el directorio
mkdir -pv $CHPATH


# Crea el archivo json
#echo "{\"run_list\": [\"recipe[emacs]\"]}" > /etc/chef/node.json
#echo -n "{\"run_list\": [\"recipe[" > $JPATH
#echo -n $CHEF_RECIPE >> $JPATH
#echo "]\"]}" >> $JPATH


# Crea el archivo solo.rb
echo "creando archivo configuracion"
echo "file_cache_path \"/tmp/chef\"" > $CPATH
echo "cookbook_path \"/tmp/chef/cookbooks\"" >> $CPATH
echo "role_path \"/tmp/chef/roles\"" >> $CPATH
echo "data_bag_path \"/tmp/chef/data_bags\"" >> $CPATH


# Copia todo al disco
echo "copiando elementos al disco"
cp -rv /mnt/cookbooks/ /tmp/chef/cookbooks/
cp -rv /mnt/roles/ /tmp/chef/roles
cp -rv /mnt/data_bags/ /tmp/chef/data_bags/

# Ejecuta Chef-solo
echo "Ejecuta chef-solo"
chef-solo -c $CPATH -j $JPATH
