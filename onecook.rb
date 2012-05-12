require 'database.rb'
require 'check_deps.rb'

class OneCook
	def self.run commands
		case

		#USO onecook list
		when commands[0] == 'list'
			raise ArgumentError if commands.length != 1
			#puts 'dentro de la lista'
			puts "ID\tNAME\t\t\tRECIPES"
			Cookbook.find(:all).each do |cb|
				puts cb.to_s
            		end

		#USO onecook update-repo 
		when commands[0] == 'import-repo'
			raise ArgumentError if commands.length != 1
			repo_path=CB_DIR
			Cookbook.find(:all).each do |cb|
				cb.enviroments.clear
				cb.delete
            		end

			Dir.entries(repo_path).each do |cb_entry|
			cb_path = CB_DIR + '/' + cb_entry
			
				if(Cookbook.isCookbook? cb_path)
					Cookbook.cb_create(cb_entry,nil)
				end
		end

=begin
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
=end

		#USO onecook create NAME [PATH]
                when commands[0] == 'create'
                        #puts 'esto es una prueba sin repo'
                        raise ArgumentError if commands.length != 2 && commands.length != 3
                        Cookbook.cb_create(commands[1],commands[2])


		#USO onecook delete ID_CB
		when commands[0] == 'delete'
			raise ArgumentError if commands.length != 2
			
			cb=Cookbook.getCookbookById(commands[1])
			if cb!=nil
				cb.enviroments.clear
				cb.delete
			end

		#USO onecook show ID_CB
		when commands[0] == 'show'
			raise ArgumentError if commands.length != 2
			
			cb=Cookbook.getCookbookById(commands[1])
			if cb!=nil
				puts Cookbook.view cb
			end

		#USO onecook update ID_CB
		when commands[0] == 'update-cb'
			raise ArgumentError if commands.length != 2
			cb=Cookbook.getCookbookById(commands[1])
			if cb!=nil
				Cookbook.update cb
			end


			
			

		#USO onecook check ID_CB
		when commands[0] == 'check'
			raise ArgumentError if commands.length != 2
			cb=Cookbook.getCookbookById(commands[1])
			if cb!=nil
				cb_name = cb.name
				deps = find_deps(CB_DIR + '/' + cb_name )
				clean_deps(deps)
				dep_str = list_deps(deps)
				puts dep_str
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
