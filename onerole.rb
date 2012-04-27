require 'database.rb'
#require 'validation/validation'
#require 'parseYAML'
#require 'uri'

class OneRole
	def self.run commands
		case

		#USO onerole list
		when commands[0] == 'list'
			raise ArgumentError if commands.length != 1
			#puts 'dentro de la lista'
		    puts "ID\tNAME\tPATH"
            Role.find(:all).each do |r|
                puts r.to_s
            end

		#USO onerole create NAME [PATH]
		when commands[0] == 'create'
			raise ArgumentError if commands.length != 2 and commands.length != 3
			Role.role_create(commands[1],commands[2])

		#USO onerole delete NAME
		when commands[0] == 'delete'
			raise ArgumentError if commands.length != 2
			if Role.exists?(:name => commands[1])
				role = Role.first(:conditions => {:name => commands[1]})
				role.enviroments.clear
				role.delete
			else
				puts 'This role don\'t exists in the database'
			end

		else
			raise ArgumentError

		end
		
	end

end
