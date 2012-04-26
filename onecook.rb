require 'database.rb'
require 'validation/validation'
require 'parseYAML'
#require 'uri'

class OneCook
	def self.run commands
		case
		#USO onecook list
		when commands[0] == 'list'
			raise ArgumentError if commands.length != 1
			#puts 'dentro de la lista'
		    puts "ID\tNAME\tPATH\tRECIPES"
            Cookbook.find(:all).each do |cb|
                puts cb.to_s
            end

		#USO onecook create NAME [PATH]
		when commands[0] == 'create'
			#puts 'esto es una prueba sin repo'
			raise ArgumentError if commands.length != 2 && commands.length != 3
			Cookbook.cb_create(commands[1],commands[2])

=begin
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
=end

		#USO onecook delete NAME
		when commands[0] == 'delete'
			raise ArgumentError if commands.length != 2
			if Cookbook.exists?(:name => commands[1])
				cb = Cookbook.first(:conditions => {:name => commands[1]})
				cb.enviroments.clear
				cb.delete
			else
				puts 'This cookbook don\'t exists'
			end

		when commands[0] == 'load'
			raise ArgumentError if commands.length != 1
			Cookbook.create(:name=>'APACHE', :path=>'/ruta/hacia/emacs')
			Cookbook.create(:name=>'MYSQL', :path=>'/ruta/hacia/vim')
			Cookbook.create(:name=>'emacs', :path=>'/ruta/hacia/emacs')
			Cookbook.create(:name=>'vim', :path=>'/ruta/hacia/vim')
			Cookbook.create(:name=>'nginx', :place=>'R')


 
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
