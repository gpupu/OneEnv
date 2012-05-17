require 'database.rb'

class OneCookHelper

	def self.list
		puts "ID\tNAME\t\t\tRECIPES"
		Cookbook.find(:all).each do |cb|
			puts cb.to_s
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

	def self.delete(idCB)
		cb=Cookbook.getCookbookById(idCB)
		if cb!=nil
			cb.delete
			return 0
		else
			return 1
		end
	end

	def self.show(idCB)
		cb=Cookbook.getCookbookById(idCB)
		if cb!=nil
			puts Cookbook.view cb
			return 0
		else
			return 1
		end

	end

	def self.update_cb(idCB)
		cb=Cookbook.getCookbookById(idCB)
		if cb!=nil
			Cookbook.update cb
			return 0
		else
			return 1
		end
	end

	def self.check(idCB)
		cb=Cookbook.getCookbookById(idCB)
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

	def self.isId(id)
            return 0, id if name.match(/^[0123456789]+$/)
        end

        def self.to_id_desc
            "OpenNebula name or id"
        end

end


