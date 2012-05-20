require 'database.rb'
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
			if(idEnv.nil?)
				env=Enviroment.getEnvByName(nameEnv)
			else	
				env=Enviroment.getEnvById(idEnv)
			end
			if env!=nil
				str_h1="%-70s"
				str=["ENVIROMENT #{env.id} INFORMATION"]
				Format_cli.print_header(str_h1,str,true)
				#puts env.view_enviroment
				Format_cli.view_env(env)
				return 0

			else
				return 1
			end
		end

		
	

		##USO:oneenv clone [-i ID_CB]|[-n NAME]
		def self.clone(idEnv,nameEnv)
			if(idEnv.nil?)
				env=Enviroment.getEnvByName(nameEnv)
			else	
				env=Enviroment.getEnvById(idEnv)
			end

			if env!=nil
				env.clone
				return 0
			else
				return 1
			end
		end


		##USO:oneenv delete [-i ID_CB]|[-n NAME]
		def self.delete(idEnv,nameEnv)
			if(idEnv.nil?)
				env=Enviroment.getEnvByName(nameEnv)
			else	
				env=Enviroment.getEnvById(idEnv)
			end


			if env!=nil
				env.delete
				return 0
			else
				return 1
			end

		end


		##USO: oneenv update-node [-i ID_CB]|[-n NAME] [NODE_PATH]
		def self.updateNode(idEnv,nameEnv,n_path)
			if(idEnv.nil?)
				env=Enviroment.getEnvByName(nameEnv)
			else	
				env=Enviroment.getEnvById(idEnv)

			end
			
			if env!=nil
				env.updateNode n_path
				return 0
			else
				return 1
			end		
		end


		##USO oneenv set-databag [-i ID_CB]|[-n NAME] [DB_PATH]
		def self.setDatabag(idEnv,nameEnv,db_path)
			if(idEnv.nil?)
				env=Enviroment.getEnvByName(nameEnv)
			else	
				env=Enviroment.getEnvById(idEnv)
			end

			if env!=nil
				env.setDatabag db_path
				return 0
			else
				return 1
			end
		end

		def self.up(id, c_path, c_deps)
			if c_path!=nil
				chef_dir = c_path
			else
				puts 'path null'
				chef_dir = CONFIG['default_solo_path'] 
			end
			puts chef_dir

			# TODO dejo esto provisional aqui hasta que lo pongamos como opcion ('-f'?), si esta a true no se evaluan dependencias
			# a false si se evaluan y se lanza la maquina o no dependiendo del resultado
			#not_dep = !c_deps

			if Enviroment.exists?(id)
				env = Enviroment.find(id)
				#idHost=commands[2]
				#puts idHost
				#repo_dir = CB_DIR + " " + ROLE_DIR
				repo_dir = ""

				# Si existen añadimos databags
				if env.databags != nil
					repo_dir << " " + env.databags
				end

				# La or tiene cortocircuito, si !c_deps es true no se llega a evaluar expand_node
				if !c_deps || expand_node(env.node)
					if c_deps
						# añadimos cookbooks
						$deps.get_cb_list.each do |cb|
							repo_dir += "#{CB_DIR}/#{cb} "
						end
						# añadimos roles
						$deps.get_role_list.each do |r|
							rfile = Role.get_filename(r)
							repo_dir += "#{ROLE_DIR}/#{rfile} "
						end
					else
						# añadimos todo
						repo_dir = CB_DIR + " " + ROLE_DIR
					end
					puts repo_dir

					c= ConectorONE.new
					c.crearTemplate(env.template, repo_dir,env.node,env.databags,chef_dir,!c_deps)
					#c.deployMV(idVM,idHost)
					puts 'montando template...'
					puts env.template
					puts repo_dir
					puts env.node
				else
					puts 'Incomplete dependencies, review that are correct or use -f option'
				end

			else 
				puts 'There is not an environment with that id'
			end
		end

		def self.addRoleDir(c_path)		
			path = File.expand_path(c_path)
			if File.exists?(path)
				roles = Dir.entries(path)
				puts roles
				roles.each do |r|
					Role.role_create(r,path) if File.extname(r) == ".rb" || File.extname(r) == ".json"

				end
			else
				puts path + ' don\'t exists'
			end
		end

		def self.updateRole(name)	
			if Role.exists?(:name => name)
				role = Role.first(:conditions=> {:name => name})
				path = File.expand_path(role.path)
				if File.exists?(path)
					puts path
					# Copiar rol en el directorio por defecto
					if path != ROLE_DIR
						cp_com = "cp -f #{path} #{ROLE_DIR}"
						system(cp_com)
					end
				else
					puts path + ' don\'t exists'
				end
			else
				puts 'This role don\'t exists'
			end
		end

		def self.listRoles()
			puts "ID\tNAME\tPATH"
            		Role.find(:all).each{|r|
                		puts r.to_s
            		}
		end

		def self.deleteRole(name)
			if Role.exists?(:name => name)
				role = Role.first(:conditions => {:name => name})
				role.delete
			else
				puts 'This role don\'t exists in the database'
			end
		end

end
