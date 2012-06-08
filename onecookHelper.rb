require 'database.rb'
require 'format_cli'

class OneCookHelper

	def self.list

		str_h1="%5s %20s %27s"
		str=["ID","NAME","NUM RECIPES"]
        	Format_cli.print_header(str_h1,str,true)
		Cookbook.find(:all).each do |cb|
			Format_cli.print_cb_line(cb)
		end
		return 0
	end

	

	def self.import_repo(path)
		path = File.expand_path(path)
		if File.exists?(path)
			cbs_list = Dir.entries(path)
			cbs_list.each do |cb|
				# Comprueba que es un CB
				cb_dir = path + '/' + cb
				puts cb_dir
				if Cookbook.isCookbook? cb_dir
					puts 'es cookbook'
					Cookbook.cb_create(cb,path)
				end
			end
			return 0
		else
			puts path + ' don\'t exists'
			return 1
		end

	end

	def self.add(name,path)
	 Cookbook.cb_create(name,path)
	end

	def self.delete(idCB,nameCB)
		if(!nameCB.nil?)
			cb=Cookbook.getCookbookByName(nameCB)
		elsif(!idCB.nil?)	
			cb=Cookbook.getCookbookById(idCB)
		else
			puts "COOKBOOK_ID/NAME argument needed for this action.\nPlease, write: 'onecook -h' for help."		
		end
		if cb!=nil
			cb.delete
			return 0
		else
			return 1
		end
	end

	def self.show(idCB,nameCB)
		if(!nameCB.nil?)
			cb=Cookbook.getCookbookByName(nameCB)
		elsif(!idCB.nil?)	
			cb=Cookbook.getCookbookById(idCB)
		else
			puts "COOKBOOK_ID/NAME argument needed for this action.\nPlease, write: 'onecook -h' for help."		
		end
		if cb!=nil
			str_h1="%-70s"
			str=["COOKBOOK #{cb.id} INFORMATION"]
			Format_cli.print_header(str_h1,str,true)
			Format_cli.view_cb(cb)
			return 0
		else
			return 1
		end
	end

	def self.update_cb(idCB,nameCB)
		if(!nameCB.nil?)
			cb=Cookbook.getCookbookByName(nameCB)
		elsif(!idCB.nil?)	
			cb=Cookbook.getCookbookById(idCB)
		else
			puts "COOKBOOK_ID/NAME argument needed for this action.\nPlease, write: 'onecook -h' for help."		
		end
		if cb!=nil
			cb.update_cb
			return 0
		else
			return 1
		end
	end

	def self.check(idCB,nameCB)
		if(!nameCB.nil?)
			cb=Cookbook.getCookbookByName(nameCB)
		elsif(!idCB.nil?)	
			cb=Cookbook.getCookbookById(idCB)
		else
			puts "COOKBOOK_ID/NAME argument needed for this action.\nPlease, write: 'onecook -h' for help."		
		end
		if cb!=nil
			cb_name = cb.name
			deps = find_deps2(CB_DIR + '/' + cb_name )
			clean_deps(deps)
			dep_str = list_deps(deps)
			puts dep_str
			return 0
		else
			return 1
		end
	end



end


