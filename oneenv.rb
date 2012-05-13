require 'database.rb'
require 'template.rb'

class OneEnv
	def self.run commands
		case commands[0]

		##USO: oneenv create NAME ID_TEMPLATE NODE_PATH [DATABAG_PATH]
		when 'create'
			raise ArgumentError if commands.length !=4 and commands.length !=5

			if File.exists?(commands[3])
				node_path = File.expand_path(commands[3])
			else 
				puts 'node path is not correct' 
			end

			if commands.length == 5 
				if File.exists?(commands[4])
					datab_path = File.expand_path(commands[4])
				else 
					puts 'databag path is not correct'
				end
			else
				datab_path = nil
			end
			
			Enviroment.create(:name=> commands[1], :template=> commands[2], :node=> node_path, :databags=> datab_path)
			

		##USO:oneenv list
		when 'list'
			raise ArgumentError if commands.length != 1
			puts "ID\tNAME\tTEMPLATE\tNODE\tDATA BAGS"
           		Enviroment.find(:all).each do |e|
				puts e.to_s
			end

		##USO:oneenv show [ID_Env]
		when 'show'	#TODO
			raise ArgumentError if commands.length != 2
			if Enviroment.exists?(commands[1])
           			env = Enviroment.find(commands[1])
					puts Enviroment.view_enviroment env
			else
				puts 'Can\'t find the enviroment ' + "#{commands[1]}"
			end
			
		##USO:oneenv clone ID_Env
		when 'clone'
			raise ArgumentError if commands.length != 2
			if Enviroment.exists?(commands[1])
				#Enviroment.clone_env(commands[1])
				Enviroment.find(commands[1]).clone
			else
				puts 'Can\'t find the enviroment ' + "#{commands[1]}"
			end

		##USO:oneenv delete [ID_Env]
		when 'delete'
			raise ArgumentError if commands.length != 2
			if Enviroment.exists?(commands[1])
				env = Enviroment.find(commands[1])
				env.cookbooks.clear
				env.roles.clear
				env.delete
				#Enviroment.delete(commands[1])
			else
				puts 'Can\'t find the enviroment ' + "#{commands[1]}"
			end

		##USO: oneenv update-node ID_ENV [NODE_PATH]
		when 'set-node'
			raise ArgumentError if commands.length != 2 and commands.length != 3
			if Enviroment.exists?(commands[1])
				#env= Enviroment.find(commands[1])
				if commands[2] != nil
					Enviroment.update(commands[1], {:node=> commands[2]})
				end
			else
				puts 'Can\'t find the enviroment ' + "#{commands[1]}"
			end

		##USO oneenv update-databags ID_ENV [DB_PATH]
		when 'set-databag'
			raise ArgumentError if commands.length != 2 and commands.length != 3
			if Enviroment.exists?(commands[1])
				env= Enviroment.find(commands[1])
				Enviroment.update(commands[1], {:databags=> commands[2]})
			else
				puts 'Can\'t find the enviroment ' + "#{commands[1]}"
			end

		##USO:oneenv up ID_entorno [CHEF_PATH]
		when 'up'
			raise ArgumentError if commands.length != 2  and commands.length != 3

			if commands.length == 3
				
				if File.exists?(commands[2])
					bootstrap_path = File.expand_path(commands[2])
				else
					bootstrap_path=nil			
				end
			else 
				bootstrap_path = nil
			end


			if commands.length == 3
				chef_dir = commands[2]
			else 
				chef_dir = CONFIG['default_solo_path'] 
			end

			if Enviroment.exists?(commands[1])
				env = Enviroment.find(commands[1])

				repo_dir = CB_DIR + " " + ROLE_DIR
				# Si existen añadimos databags
				if env.databags != nil
					repo_dir << " " + env.databags
				end

				c= ConectorONE.new
				idVM=c.crearTemplate(env.template.to_i, repo_dir,env.node,env.databags,bootstrap_path,chef_dir)
				c.deployMV(idVM,1)


			else 
				puts 'There is not an environment with that id'
			end

		##USO: oneenv add-role-dir PATH
		when 'add-role-dir'	
			raise ArgumentError if commands.length != 2
			path = File.expand_path(commands[1])
			if File.exists?(path)
				roles = Dir.entries(path)
				puts roles
				roles.each do |r|
					# Los roles pueden ser ruby o json
					if File.extname(r) == ".rb"
						rname = File.basename(r,".rb")
						rpath = path + '/' + r
						Role.role_create(rname,rpath) 
					end
					if File.extname(r) == ".json"
						rname = File.basename(r,".json")
						rpath = path + '/' + r
						Role.role_create(rname,rpath) 
					end

				end
			else
				puts path + ' don\'t exists'
			end

		##USO: oneenv update-role NAME
		when 'update-role'	
			raise ArgumentError if commands.length != 2
			if Role.exists?(:name => commands[1])
				role = Role.first(:conditions=> {:name => commands[1]})
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

		#USO oneenv list-roles
		when 'list-roles'
			raise ArgumentError if commands.length != 1
			#puts 'dentro de la lista'
		    puts "ID\tNAME\tPATH"
            Role.find(:all).each{|r|
                puts r.to_s
            }

		#USO oneenv delete-role NAME
		when 'delete-role'
			raise ArgumentError if commands.length != 2
			if Role.exists?(:name => commands[1])
				role = Role.first(:conditions => {:name => commands[1]})
				role.delete
			else
				puts 'This role don\'t exists in the database'
			end

		else
			raise ArgumentError

		end

	end

end


begin
	OneEnv.run ARGV
	rescue ArgumentError
	puts "Argument error"
end
