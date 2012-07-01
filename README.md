# OneEnv #
Environment provisioning tool for OpenNebula

## Description ##
OneEnv is an environment provisioning tool that adds OpenNebula the ability to deploy environments in an easy and flexible way. The user would be able to write different agnostic configurations as code powered by Chef Solo.

## Requirements ##
Any OpenNebula version with contextualization support should work, but it is recommended 3.0 or higher where OneEnv has been tested.

OneEnv works with "base templates" based on "base image". Where "Base Image" is an OpenNebula image with minimum installation:
* Chef Solo 0.10.x or higher must be installed to execute configurations
* /etc/rc.local must be configured to mount context image in /mnt and run /mnt/init.sh. Example:

```sh
#!/bin/sh -e
mount -t iso9660 /dev/vdb /mnt/
if [ -f /mnt/init.sh ]; then
	. /mnt/init.sh
fi
umount /mnt
exit 0
```

## Installation ##
To install OneEnv, OpenNebula must be installed first. Then run `install.sh` script as OpenNebula admin (oneadmin user). OneEnv commands will be integrated in OpenNebula.
	
## Configuration ##
By default , all cookbooks and roles included will be copy to var/chef directory. Different directories may be selected if needed by modifying `default_cb_dir` and `default_role_dir` variables in /etc/oneenv.conf file.
	
## Operations ##

### Commands ###
#### oneenv ####
	
	create <NAME> <ID_TEMPLATE> <NODE_PATH> [-p <DATABAG_PATH>]
		Creates a new Enviroment.
	list
		Lists all Enviroments.
	clone [-i <ID_Env>]|[-n <NAME_Env>]
		Clones an existing Enviroment
	show [-i <ID_Env>]|[-n <NAME_Env>]
		Prints the information of an existing Enviroment
	delete [-i <ID_Env>]|[-n <NAME_Env>]
		Deletes an existing Enviroment
	update-node [-i <ID_Env>]|[-n <NAME_Env>] [<NODE_PATH>]
		Changes the path of the Enviroment's node
	set-databags [-i <ID_Env>]|[-n <NAME_Env>] <DB_PATH>
		Sets a Databag path to an existing Enviroment
	up [-i <ID_Env>]|[-n <NAME_Env>] [-p <CHEF_PATH>]
		Launches the given Enviroment
			
#### onecook ####

	add <NAME> [-p <PATH>]
		Adds a new a Cookbook to the repository.
	list
		Lists all Cookbooks
	import-repo <PATH>
		Imports all the Cookbooks to the repository from the given path
	delete [-n <COOKBOOK_NAME>]|[-i <COOKBOOK_ID>]
		Deletes the given Cookbook
	show [-n <COOKBOOK_NAME>]|[-i <COOKBOOK_ID>]
		Prints the information of the given Cookbook
	update-cb [-n <COOKBOOK_NAME>]|[-i <COOKBOOK_ID>]
		Updates the given Cookbook
	check [-n <COOKBOOK_NAME>]|[-i <COOKBOOK_ID>]
		Checks the dependencies of the given Cookbook
			
#### onerole ####
	
	add <PATH>
		Adds a Role from path
	delete <NAME>
		Deletes a given Role
	show <NAME>
		Shows information about the given Role
	update <NAME>
		Updates the given Role
	list
		Lists the Roles	
	import-repo <PATH>
		Adds all Roles from a directory path
			
			
### Options ###
		
	-c, --check
		Check dependencies when up a environment
	-i, --id ID_ENV
		References environment, cookbook or role by ID
	-n, --name NAME_ENV
		References environment, cookbook or role by Name
	-p, --path
		This is the databag, cookbook or node path	
	-h, --help
		Show command help

## Notes ##
* It is recommended to use roles in JSON format. Anyway, if Ruby files are used, be sure to include `run_list` as an inline instruction
* Make sure dependencies are declared in this format: `include_recipe "cookbook_name::recipe_name"` as inline instructions and not variables when using `-c`, `--check` option.

## Authors ##
This tool has been cloned from [original project](http://code.google.com/p/ssii-1112-ucm/) (http://code.google.com/p/ssii-1112-ucm/), written by David Baena, José Gabriel Puado and Fernando Martínez-Conde as CS degree's final project.
