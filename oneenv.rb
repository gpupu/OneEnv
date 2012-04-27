require 'database.rb'
require 'validation/validation'
require 'parseYAML'
#require 'template.rb'

class OneEnv
	def self.run commands
		case commands[0]

		##USO: oneenv create NAME ID_TEMPLATE NODE_PATH [DATABAG_PATH]
		when 'create'
			raise ArgumentError if commands.length !=4 and commands.length !=5
			# TODO: Comprobar que el template existe en opennebula
			# TODO: Comprobar dependencias del NODE¿?
			node_path = File.expand_path(commands[3])
			if File.exists?(node_path)
				Enviroment.create(:name=> commands[1], :template=> commands[2], :node=> node_path, :databags=> commands[4])
			else
				puts 'node path is not correct'
			end

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

		##USO: oneenv update-node ID_ENV NODE_PATH
		when 'update-node'
			raise ArgumentError if commands.length != 3
			if Enviroment.exists?(commands[1])
				env= Enviroment.find(commands[1])
				# limpia lista de roles y cbs
				#env.cookbooks.clear
				#env.roles.clear
				# recorre el arbol marcando contenidos
			else
				puts 'Can\'t find the enviroment ' + "#{commands[1]}"
			end

		##USO oneenv update-databags ID_ENV [DB_PATH]
		when 'update-databag'
			raise ArgumentError if commands.length != 2 and commands.length != 3
			if Enviroment.exists?(commands[1])
				env= Enviroment.find(commands[1])
				Enviroment.update(commands[1], {:databags=> commands[2]})
			else
				puts 'Can\'t find the enviroment ' + "#{commands[1]}"
			end


=begin
		##USO:oneenv clone [ID_Env]
		when 'clone'
			raise ArgumentError if commands.length != 2
			if Enviroment.exists?(commands[1])
				Enviroment.clone_env(commands[1])
			else
				puts 'Can\'t find the enviroment ' + "#{commands[1]}"
			end

		##USO:oneenv add-ssh [ID_entorno] [SSH_path]
		when 'add-ssh'
			raise ArgumentError if commands.length != 3
			if validationSSH(commands[2])
				Enviroment.addSSH(commands[1],commands[2])
			else
				puts "#{commands[2]} is not a valid SSH"
			end
		##USO:oneenv update-ssh [ID_entorno] [SSH_path]
		when 'update-ssh'

			raise ArgumentError if commands.length != 3
			if validationSSH(commands[2])
				Enviroment.addSSH(commands[1],commands[2])
			else
				puts "#{commands[2]} is not a valid SSH"
			end
=end

		##USO:oneenv up [ID_entorno] 
		when 'up'	#TODO
			raise ArgumentError if commands.length != 2
			if Enviroment.exists?(commands[1])
				env = Enviroment.find(commands[1])
				#node = env.node
# 	TODO Pasar directorio databags
				repo_dir = CB_DIR + ' ' + ROLE_DIR
				#constructTemplate(env.template.to_i, repo_dir,env.node )
				puts 'montando template...'
				puts env.template
				puts repo_dir
				puts env.node
			else 
				puts 'There is not an environment with that id'
			end

=begin
		##USO:oneenv add-cookbook [ID_entorno] [cb_name]
		when 'add-cookbook'
			raise ArgumentError if commands.length != 3
			if Enviroment.exists?(commands[1])
				Enviroment.add_cookbook(commands[1],commands[2])
			else
				puts 'Can\'t find the enviroment ' + "#{commands[1]}"
			end


		when 'update-cookbook'

		##USO:oneenv delete-cookbook [ID_entorno] [cb_name]
		when 'delete-cookbook'
			raise ArgumentError if commands.length != 3
			if Enviroment.exists?(commands[1])
				Enviroment.delete_cookbook(commands[1],commands[2])
			else
				puts 'This enviroment don\'t exists'
			end
=end
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
