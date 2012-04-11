require 'database.rb'
require 'validation/validation'
require 'parseYAML'
require 'templates.rb'

class OneEnv
	def self.run commands
		case commands[0]

		##USO: oneenv create [YAML] 
		when 'create'
			raise ArgumentError if commands.length != 2
			cad2=commands[1]
			#Aqui se comprueba si el fichero es valido. He puesto como que haya que meter obligatoriamente el fichero por parametro. El metodo 				validationYAML esta en validation.rb		
			if validationYAML(cad2)
				#converter es el metodo de parseYAML.rb
				aux=converter(cad2)
				aux.each do |f|
					#Para cada elemento de la lista de entornos hacemos un add
					Enviroment.add(f)
				end
			else 
				'No se ha podido crear'
			end

		##USO:oneenv list
		when 'list'
			raise ArgumentError if commands.length != 1
			puts "ID\tNAME\tIMAGE\tTYPE\tSSH\tNETWORK\tCOOKBOOKS"
           	Enviroment.find(:all).each do |e|
				puts e.to_s
			end

		##USO:oneenv show [ID_Env]
		when 'show'
			raise ArgumentError if commands.length != 2
			puts "ID\tNAME\tIMAGE\tTYPE\tSSH\tNETWORK\tCOOKBOOKS"
			if Enviroment.exists?(commands[1])
           		e =Enviroment.find(commands[1])
			else
				puts 'This enviroment dont\' exits'
			end
			puts e.to_s

		##USO:oneenv delete [ID_Env]
		when 'delete'
			raise ArgumentError if commands.length != 2
			if Enviroment.exists?(commands[1])
				Enviroment.delete(commands[1])
			else
				puts 'This enviroment don\'t exists'
			end

		##USO:oneenv clone [ID_Env]
		when 'clone'
			raise ArgumentError if commands.length != 2
			if Enviroment.exists?(commands[1])
				Enviroment.clone_env(commands[1])
			else
				puts 'This enviroment don\'t exists'
			end

		
		when 'add-ssh'
			raise ArgumentError if commands.length != 3
			if validationSSH(commands[2])
				Enviroment.addSSH(commands[1],commands[2])
			else
				puts "#{commands[2]} is not a valid SSH"
			end

		when 'update-ssh'

		##USO:oneenv up [ID_entorno]
		when 'up'


		##USO:oneenv add-cookbook [ID_entorno] [cb_name]
		when 'add-cookbook'
			raise ArgumentError if commands.length != 3
			if Enviroment.exists?(commands[1])
				Enviroment.add_cookbook(commands[1],commands[2])
			else
				puts 'This enviroment don\'t exists'
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
		when 'create-template'
			raise ArgumentError if commands.length != 2
			if Enviroment.exists?(commands[1])
				entorno= Enviroment.find(commands[1])
				constructTemplate(entorno)
			else 
				puts 'There is not an environment with that id'
			end
		else
			raise ArgumentError

		end

	end

end

OneEnv.run ARGV
