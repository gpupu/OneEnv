# --------------------------------------------------------------------------#
# Copyright 2012   David Baena, Fernando Martínez-Conde, José Gabriel Puado	#
# 																			#
# Licensed under the Apache License, Version 2.0 (the "License"); you may 	#
# not use this file except in compliance with the License. You may obtain 	#
# a copy of the License at 													#
# 																			#
# http://www.apache.org/licenses/LICENSE-2.0 								#
# 																			#
# Unless required by applicable law or agreed to in writing, software 		#
# distributed under the License is distributed on an "AS IS" BASIS, 		#
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 	#
# See the License for the specific language governing permissions and 		#
# limitations under the License. 											#
#---------------------------------------------------------------------------#

require 'oneenv/database.rb'
require 'cli/oneenv_helper/format_cli.rb'

class OneCookHelper

	def self.list

		str_h1="%5s %20s %27s"
		str=["ID","NAME","NUM RECIPES"]
        	Format_cli.print_header(str_h1,str,true)
		Cookbook.find(:all).each do |cb|
			Format_cli.print_cb_line(cb)
		end
	end

	

	def self.import_repo(path)
		path = File.expand_path(path)
		if File.exists?(path)
			cbs_list = Dir.entries(path)
			cbs_list.each do |cb|
				# Make sure is a cookbook
				cb_dir = path + '/' + cb
				puts cb_dir
				if Cookbook.isCookbook? cb_dir
					puts 'es cookbook'
					Cookbook.cb_create(cb,path)
				end
			end
		else
			puts path + ' don\'t exists'
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
		end
		if cb!=nil
			cb.delete
		end
	end

	def self.show(idCB,nameCB)
		if(!nameCB.nil?)
			cb=Cookbook.getCookbookByName(nameCB)
		elsif(!idCB.nil?)	
			cb=Cookbook.getCookbookById(idCB)	
		end
		if cb!=nil
			str_h1="%-70s"
			str=["COOKBOOK #{cb.id} INFORMATION"]
			Format_cli.print_header(str_h1,str,true)
			Format_cli.view_cb(cb)
		end
	end

	def self.update_cb(idCB,nameCB)
		if(!nameCB.nil?)
			cb=Cookbook.getCookbookByName(nameCB)
		elsif(!idCB.nil?)	
			cb=Cookbook.getCookbookById(idCB)		
		end
		if cb!=nil
			cb.update_cb
		end
	end

	def self.check(idCB,nameCB)
		if(!nameCB.nil?)
			cb=Cookbook.getCookbookByName(nameCB)
		elsif(!idCB.nil?)	
			cb=Cookbook.getCookbookById(idCB)	
		end
		if cb!=nil
			cb_name = cb.name
			deps = find_deps2(CB_DIR + '/' + cb_name )
			clean_deps(deps)
			dep_str = list_deps(deps)
			puts dep_str
		end
	end



end


