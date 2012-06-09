require 'database.rb'
require 'check_runlist.rb'
require 'template.rb'
require 'format_cli'

class OneEnvHelper

		def self.create(name,id,n_path,d_path)
		#si se intenta crear 2 entornos con el mismo nombre la 2ª vez no hace nada pero tp. dice nada.
			if File.exists?(n_path)
				node_path = File.expand_path(n_path)
			else 
				puts 'node path is not correct' 
			end

			if d_path!=nil
				if File.exists?(d_path)
					datab_path = File.expand_path(d_path)
				else 
					puts 'databag path is not correct'
				end
			else
				datab_path = nil
			end
			
			Enviroment.create(:name=> name, :template=> id, :node=> node_path, :databags=> datab_path)
		end

		def self.list()
			str_h1="%3s %-11s %-11s %-24s %-24s"
			str=["ID","NAME","TEMPLATE","NODE","DATABAGS"]
			Format_cli.print_header(str_h1,str,true)
           		Enviroment.find(:all).each do |e|
				Format_cli.print_env_line(e)
			end
		end


		##USO:oneenv show [-i ID_CB]|[-n NAME]
		def self.show(idEnv,nameEnv)
			if(!nameEnv.nil?)
				env=Enviroment.getEnvByName(nameEnv)
			elsif(!idEnv.nil?)	
				env=Enviroment.getEnvById(idEnv)
			else
				puts "ENVIROMENT_ID/NAME argument needed for this action.\nPlease, write: 'oneenv -h' for help."		
			end

			if env!=nil
				str_h1="%-70s"
				str=["ENVIROMENT #{env.id} INFORMATION"]
				Format_cli.print_header(str_h1,str,true)
				Format_cli.view_env(env)
			end
		end

		
	

		##USO:oneenv clone [-i ID_CB]|[-n NAME]
		def self.clone(idEnv,nameEnv)
			if(!nameEnv.nil?)
				env=Enviroment.getEnvByName(nameEnv)
			elsif(!idEnv.nil?)	
				env=Enviroment.getEnvById(idEnv)
			else
				puts "ENVIROMENT_ID/NAME argument needed for this action.\nPlease, write: 'oneenv -h' for help."		
			end
			if env!=nil
				env.clone
			end
		end


		##USO:oneenv delete [-i ID_CB]|[-n NAME]
		def self.delete(idEnv,nameEnv)
			if(!nameEnv.nil?)
				env=Enviroment.getEnvByName(nameEnv)
			elsif(!idEnv.nil?)	
				env=Enviroment.getEnvById(idEnv)
			else
				puts "ENVIROMENT_ID/NAME argument needed for this action.\nPlease, write: 'oneenv -h' for help."		
			end

			if env!=nil
				env.delete
			end

		end


		##USO: oneenv update-node [-i ID_CB]|[-n NAME] [NODE_PATH]
		def self.updateNode(idEnv,nameEnv,n_path)
			if(!nameEnv.nil?)
				env=Enviroment.getEnvByName(nameEnv)
			elsif(!idEnv.nil?)	
				env=Enviroment.getEnvById(idEnv)
			else
				puts "ENVIROMENT_ID/NAME argument needed for this action.\nPlease, write: 'oneenv -h' for help."		
			end
			
			if env!=nil
				env.updateNode n_path
			end		
		end


		##USO oneenv set-databag [-i ID_CB]|[-n NAME] [DB_PATH]
		def self.setDatabag(idEnv,nameEnv,db_path)
			if(!nameEnv.nil?)
				env=Enviroment.getEnvByName(nameEnv)
			elsif(!idEnv.nil?)	
				env=Enviroment.getEnvById(idEnv)
			else
				puts "ENVIROMENT_ID/NAME argument needed for this action.\nPlease, write: 'oneenv -h' for help."		
			end

			if env!=nil
				env.setDatabag db_path
			end
		end

		def self.up(id, c_path,c_deps)
			if c_path!=nil
				chef_dir = c_path
			else
				chef_dir = CONFIG['default_solo_path'] 
			end

			if Enviroment.exists?(id)
				env = Enviroment.find(id)
				repo_dir = ""

				# Si existen añadimos databags
				if env.databags != nil && 					
					if !File.exists?(env.databags)
						puts env.databags + ' don\'t exists'
						exit
					end
					repo_dir << " " + env.databags
				end
				


				if !File.exists?(env.node)
					puts env.node + ' don\'t exists'
					exit
				end
				
				
				expand=contain_roles(env.node)
				if(expand || c_deps)
					dep_resueltas=expand_node(env.node)


					# añadimos cookbooks
					array_cb=$deps.get_cb_list

					##quitamos repeticiones
					array_cb.each do |cb|
						repo_dir += "#{CB_DIR}/#{cb} "
					end

					# añadimos roles
					array_roles=$deps.get_role_list
					puts array_roles
					##quitamos repeticiones
					array_roles.each do |r|
						rfile = Role.get_filename(r)
						repo_dir += "#{ROLE_DIR}/#{rfile} "
					end

					#Creamos template
					if(!dep_resueltas)
						puts 'Incomplete dependencies, review that are correct'
						exit
					end

					c= ConectorONE.new
					c.crearTemplate(env.template, repo_dir,env.node,env.databags,chef_dir,$deps)
				

				else
					# añadimos cookbooks
					list_resources=check_runlist(env.node)
					array_cb=list_resources.cookbooks_list
					if(!array_cb.empty?)
						array_cb.each do |cb|
							repo_dir += "#{CB_DIR}/#{cb} "
						end
					end
					
					c= ConectorONE.new
					c.crearTemplate(env.template, repo_dir,env.node,env.databags,chef_dir,list_resources)
				end

			else 
				puts 'There is not an environment with that id'
			end
		end


end
