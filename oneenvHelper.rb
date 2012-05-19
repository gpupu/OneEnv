require 'database.rb'
require 'template.rb'

class OneEnvHelper
		##USO: oneenv create NAME ID_TEMPLATE NODE_PATH [DATABAG_PATH]
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

		##USO:oneenv list
		def self.list()
			puts "ID\tNAME\tTEMPLATE\tNODE\tDATA BAGS"
           		Enviroment.find(:all).each do |e|
				puts e.to_s
			end
		end

		##USO:oneenv show [ID_Env]
		def self.show(id)	#TODO
			if Enviroment.exists?(id)
           			#env = Enviroment.find(id) 
				#puts env
				#puts Enviroment.view_enviroment env
				#Esto creo que esta mal porque el view funciona con id
				puts Enviroment.view_enviroment id
			else
				puts 'Can\'t find the enviroment ' + "#{id}"
			end
		end		
	
		##USO:oneenv clone ID_Env
		def self.clone(id)
			if Enviroment.exists?(id)
				#Enviroment.clone_env(commands[1])
				Enviroment.find(id).clone
			else
				puts 'Can\'t find the enviroment ' + "#{id}"
			end
		end

		##USO:oneenv delete [ID_Env]
		def self.delete(id)
			if Enviroment.exists?(id)
				env = Enviroment.find(id)
				#env.cookbooks.clear
				#env.roles.clear
				env.delete
				#Enviroment.delete(commands[1])
			else
				puts 'Can\'t find the enviroment ' + "#{id}"
			end
		end

		##USO: oneenv update-node ID_ENV [NODE_PATH]
		def self.updateNode(id,n_path)
			if Enviroment.exists?(id)
				#env= Enviroment.find(commands[1])
				if n_path != nil
					Enviroment.update(id, {:node=> n_path})
				end
			else
				puts 'Can\'t find the enviroment ' + "#{id}"
			end
		end

		##USO oneenv set-databag ID_ENV [DB_PATH]
		def self.setDatabag(id,db_path)
			if Enviroment.exists?(id)
				env= Enviroment.find(id)
				Enviroment.update(id, {:databags=> db_path})
			else
				puts 'Can\'t find the enviroment ' + "#{id}"
			end
		end

		##USO:oneenv up ID_entorno [CHEF_PATH]
		def self.up(id, c_path)
			if c_path!=nil
				chef_dir = c_path
			else 
				chef_dir = CONFIG['default_solo_path'] 
			end

			# TODO dejo esto provisional aqui hasta que lo pongamos como opcion ('-f'?), si esta a true no se evaluan dependencias
			# a false si se evaluan y se lanza la maquina o no dependiendo del resultado
			not_dep = false

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

				
				# La or tiene cortocircuito, si not_dep es true no se llega a evaluar expand_node
				if not_dep || expand_node(env.node)

					if !not_dep
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
					c.crearTemplate(env.template.to_i, repo_dir,env.node,env.databags,chef_dir,not_dep)
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

		##USO: oneenv add-role-dir PATH
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

		##USO: oneenv update-role NAME
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

		#USO oneenv list-roles
		def self.listRoles()
			puts "ID\tNAME\tPATH"
            		Role.find(:all).each{|r|
                		puts r.to_s
            		}
		end

		#USO oneenv delete-role NAME
		def self.deleteRole(name)
			if Role.exists?(:name => name)
				role = Role.first(:conditions => {:name => name})
				role.delete
			else
				puts 'This role don\'t exists in the database'
			end
		end

end
