require 'database.rb'
#require 'validation/validation'
#require 'parseYAML'
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

		#USO onecook add-dir PATH
		when commands[0] == 'add-dir'
			#puts 'esto es una prueba sin repo'
			raise ArgumentError if commands.length != 2
			path = File.expand_path(commands[1])
			if File.exists?(path)
				cbs_list = Dir.entries(path)
				cbs_list.each do |cb|
					# Comprueba que es un CB
					cb_dir = path + '/' + cb
					puts cb_dir
					if Cookbook.isCookbook? cb_dir
						Cookbook.cb_create(cb,path)
					end

				end

			else
				puts path + ' don\'t exists'
			end

		#USO onecook create NAME [PATH]
		when commands[0] == 'create'
			#puts 'esto es una prueba sin repo'
			raise ArgumentError if commands.length != 2 && commands.length != 3
			Cookbook.cb_create(commands[1],commands[2])


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

		#USO onecook show NAME
		when commands[0] == 'show'
			raise ArgumentError if commands.length != 2
			if Cookbook.exists?(:name => commands[1])
				puts Cookbook.view commands[1]
			else
				puts 'Can\'t find the cookbook ' + "#{commands[1]}"
			end

		#USO onecook update NAME
		when commands[0] == 'update'
			raise ArgumentError if commands.length != 2
			if Cookbook.exists?(:name => commands[1])
				Cookbook.update commands[1]
			else
				puts 'Can\'t find the cookbook ' + "#{commands[1]}"
			end

=begin
		when commands[0] == 'load'
			raise ArgumentError if commands.length != 1
			Cookbook.create(:name=>'APACHE', :path=>'/ruta/hacia/emacs')
			Cookbook.create(:name=>'MYSQL', :path=>'/ruta/hacia/vim')
			Cookbook.create(:name=>'emacs', :path=>'/ruta/hacia/emacs')
			Cookbook.create(:name=>'vim', :path=>'/ruta/hacia/vim')
			Cookbook.create(:name=>'nginx', :place=>'R')

=end
 
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
