#!/bin/bash

readonly JPATH="/tmp/chef/node.json"
readonly CPATH="/tmp/chef/solo.rb"

# Crea el directorio
mkdir -pv /tmp/chef

# Crea el archivo json
#echo "{\"run_list\": [\"recipe[emacs]\"]}" > /etc/chef/node.json
echo -n "{\"run_list\": [\"recipe[" > $JPATH
echo -n $CHEF_RECIPE >> $JPATH
echo "]\"]}" >> $JPATH

# Crea el archivo solo.rb
echo "file_cache_path \"/tmp/chef\"" > $CPATH
echo "cookbook_path \"/tmp/chef/cookbooks\"" >> $CPATH

# Copia las recetas al disco
cp -rv /mnt/recipes/ /tmp/chef/cookbooks/

# Ejecuta Chef-solo
echo "Ejecuta chef-solo"
chef-solo -c $CPATH -j $JPATH
