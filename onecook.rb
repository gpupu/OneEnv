require 'database.rb'
require 'validation/validation'
require 'parseYAML'
require 'uri'

class OneCook
	def self.run commands
		case
		when commands[0] == 'list'
			raise ArgumentError if commands.length != 1
			#puts 'dentro de la lista'
		    puts "ID\tNAME\tPATH\tPLACE"
            Cookbook.find(:all).each do |cb|
                puts cb.to_s
            end

		when commands[0] == 'create' && commands[1] != '--from-repo'
			#puts 'esto es una prueba sin repo'
			raise ArgumentError if commands.length != 2 && commands.length != 3
			Cookbook.cb_create(commands[1],commands[2],false)

		when commands[0] == 'create' && commands[1] == '--from-repo'
			#puts 'esto es una prueba CON repo'
			raise ArgumentError if commands.length != 3 && commands.length != 4
			unless (commands[3] =~ URI::regexp).nil?
				Cookbook.cb_create(commands[2],commands[3],true)
			else 
				puts "'#{commands[3]}' has not a valid URL format"
			end
		when commands[0] == 'update' && commands[1] != '--from-repo'			
			raise ArgumentError if commands.length != 2 && commands.length != 3

			if Cookbook.exists?(:name => commands[1])
				cb = Cookbook.first(:conditions => {:name => commands[1]})
				Cookbook.update(cb.id, {:path=> commands[2], :place => 'L'})
			else
				puts 'This cookbook don\'t exists'
			end

		when commands[0] == 'update' && commands[1] == '--from-repo'
			raise ArgumentError if commands.length != 3 && commands.length != 4
			unless (commands[3] =~ URI::regexp).nil?
				if Cookbook.exists?(:name => commands[2])
					cb = Cookbook.first(:conditions => {:name => commands[2]})
					Cookbook.update(cb.id, {:path=> commands[3], :place => 'R'})
				else
					puts 'This cookbook don\'t exists'
				end
			else puts "'#{commands[3]}' has not a valid URL format"
			end

		when commands[0] == 'delete'
			raise ArgumentError if commands.length != 2
			if Cookbook.exists?(:name => commands[1])
				Cookbook.delete_all(:name => commands[1])
				Enviroment.delete_allCB commands[1]

			else
				puts 'This cookbook don\'t exists'
			end

		else
			raise ArgumentError

		end
		
	end

end


begin
	OneCook.run ARGV
	rescue ArgumentError
	puts "Argument error"
end
