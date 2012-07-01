#!/usr/bin/env ruby

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

require 'rubygems'
require 'active_record'
require 'oneenv/check_deps.rb'

#ONE_LOCATION=ENV["ONE_LOCATION"]

if !ONE_LOCATION
    ONE_ETC_LOCATION="/etc/one"
    ONE_DB_LOCATION="/var/lib/one"
    
else
    ONE_ETC_LOCATION=ONE_LOCATION+"/etc"
    ONE_DB_LOCATION=ONE_LOCATION+"/var"
end


CONFIG_FILE = ONE_ETC_LOCATION+"/oneenv.conf"
DB_FILE = ONE_DB_LOCATION+"/oneenv.db"

begin
	CONFIG = YAML.load_file(CONFIG_FILE)
	CB_DIR = File.expand_path(CONFIG['default_cb_dir'])
	ROLE_DIR = File.expand_path(CONFIG['default_role_dir'])
rescue Errno::ENOENT => notfound
	puts "Not Found oneenv.conf"
	exit
rescue  => badargument
	puts "Bad argument in oneenv.conf"
	exit 

end



ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => DB_FILE)

class Cookbook < ActiveRecord::Base
	validates_uniqueness_of :name
	serialize :recipes, Array
	serialize :recipes_deps, Hash

	public
	def to_s
		s  = id.to_s + "\t"
		s += name + "\t\t\t"
		s += recipes.length.to_s + "\t"
		s
	end

	public
	def update_cb
		self.recipes = Cookbook.get_recipes(self.path)
		self.save
	end
		
	public
	def view_cookbook

			s  = "NAME:\t" + self.name + "\n"
			s += "PATH:\t" + self.path + "\n"
			s += "RECIPES:\t" 
				self.recipes.each{|r| s += "\n " + r }
			s += "\nDEPENDENCIES:\t" 
				self.recipes_deps.each do|r,w|
					s += "\n " + r
					w.map { |i| s +="'" + i.to_s + "'" }.join(",")
				end

			s += "\n"
		return s
	end

	public
    	def self.cb_create cb_name , cb_path
        if (cb_path == nil) || (cb_path==CB_DIR)
			isextern = false
			source=CB_DIR + '/' + cb_name
			dest=CB_DIR
	else
			isextern=true
			source=cb_path + '/' + cb_name
			dest=CB_DIR
        end

        if !exists?(:name => cb_name)
			if File.exists?(source)
				iscopy=true
				if isextern
					cp_com = "cp -r #{source} #{dest}" 
					puts cp_com
                  			iscopy = system(cp_com)
				end
				
                if iscopy
					puts "adding cookbook: #{cb_name}"
					source = CB_DIR + '/' + cb_name
					create(:name => cb_name, :path => source, :recipes => get_recipes(source), :recipes_deps=>find_deps2(source))
                else
					puts "copying cookbook: #{cb_name} failed"
                end
			else
				puts source + ' is not a correct path'
			end
		else
			puts cb_name + ' is yet on the database'
		end
	end

	public
	def self.get_recipes path
		r_path = path   + '/recipes'
		recs = Dir.entries(r_path)
		
		if recs.size > 2
			recipe_names= Array.new
			recs.each{|r|
				if File.extname(r) == ".rb"
					recipe_names << File.basename(r,".rb")
				end
			}
			return recipe_names
		else
			return []
		end
	end

	public
	def self.isCookbook? cb_dir
		iscoobook=false
		if File.directory?(cb_dir)
			cont= Dir.entries cb_dir
			# is a cookbook if include metadata file
			iscoobook=cont.include?('metadata.rb')
		end
		return iscoobook
	end
	
	public
	def self.getCookbookById cb_id
		if Cookbook.exists?(:id => cb_id)
			cb=Cookbook.first(:conditions=>{:id=>cb_id})
			return cb					
		else
			puts 'Can\'t find the cookbook with id: ' + cb_id + ' in the database'
			return nil
		end
	end

	public
	def self.getCookbookByName cb_name
		if Cookbook.exists?(:name => cb_name)
			cb=Cookbook.first(:conditions=>{:name=>cb_name})
			return cb					
		else
			puts 'Can\'t find the cookbook with name: ' + cb_name + ' in the database'
			return nil
		end
	end

	


end


class Role < ActiveRecord::Base
	validates_uniqueness_of :name
	serialize :deps_roles, Array
	serialize :deps_recs, Array

	public
	def to_s
		s  = id.to_s + "\t"
		s += name + "\t"
		s += path + "\t"
		s += deps_roles.to_s + "\t"
		s += deps_recs.to_s + "\t"
	end


	public
	def self.get_recipes_list(r_path)
		# reading run_list
		if File.extname(r_path) == ".rb"
			rdeps = get_ruby_runl(r_path)
		end
        if File.extname(r_path) == ".json"
			rdeps = get_json_runl(r_path)
		end
		
		# get recipes
		recs_list = []
		rdeps.each do |d|
			if d.start_with?('recipe')
				d = d[7..-2]	
				recs_list.push d
			end
		end
		return recs_list
	end	
			



	public 
	def self.get_roles_list(r_path)
		# reading run_list
		if File.extname(r_path) == ".rb"
			rdeps = get_ruby_runl(r_path)
		end
        if File.extname(r_path) == ".json"
			rdeps = get_json_runl(r_path)
		end	
		
		#get recipes
		roles_list = []
		rdeps.each do |d|
			if d.start_with?('role')
		                d = d[5..-2]    #toma solo el interior
		                roles_list.push d
		        end
		end
		return roles_list
	end



	public
	def self.role_create r_name, r_path
		r_path = File.expand_path(r_path)
		if (r_path == nil)  || (r_path==ROLE_DIR)
			isextern = false
			source=ROLE_DIR + '/' + r_name
			dest=ROLE_DIR
		else
			isextern=true
			source = r_path + '/' + r_name
			dest=ROLE_DIR
		end

		if !exists?(:name=>r_name)
			if File.exists?(r_path)
			iscopy=true
				if isextern
					cp_com = "cp -r #{source} #{dest}" 
					puts cp_com
					iscopy = system(cp_com)
				end

				if iscopy
					r_path +="/#{r_name}"
					puts r_path
					recs_list=get_recipes_list(r_path)
					puts recs_list
					roles_list=get_roles_list(r_path)
					puts roles_list

                                        if File.extname(r_name) == ".rb"
                                                r_name = File.basename(r_name, ".rb")
                                                puts "ruby "+ r_name
                                        end
                                        if File.extname(r_name) == ".json"
                                                r_name = File.basename(r_name, ".json")
                                                puts "json "+ r_name
                                        end 					



					create(:name=> r_name, :path=> r_path, :deps_roles=>roles_list, :deps_recs=>recs_list )
				else
					puts "copying role #{r_name} failed"
				end

			else
				puts r_path + ' is not a correct path'
			end
		else
			puts r_name + ' is yet on the database'
		end
	end


	public
	def self.get_filename rname
		if Role.exists?(:name => rname)
			role=Role.first(:conditions=>{:name=>rname})
			rfile=role.path
			rfile = File.basename(rfile)
			rfile
			return rfile					
		else
			puts 'Can\'t find the role with name: ' + rname
			return nil
		end

	end


	public
	def self.getRoleById role_id
		if Role.exists?(:id => role_id)
			role=Role.first(:conditions=>{:id=>role_id})
			return role					
		else
			puts 'Can\'t find the role with id: ' + role_id + ' in the database'
			return nil
		end
	end

	public
	def self.getRoleByName role_name
		if Role.exists?(:name => role_name)
			role=Role.first(:conditions=>{:name=>role_name})
			return role					
		else
			puts 'Can\'t find the role with name: ' + role_name + ' in the database'
			return nil
		end
	end

	public 
	def update_role
		r_path=self.path
		recs_list=Role.get_recipes_list(r_path)
		roles_list=Role.get_roles_list(r_path)
		self.deps_roles=roles_list
		self.deps_recs=recs_list
		self.save
	end


end

class Enviroment < ActiveRecord::Base

	validates_uniqueness_of :name
	after_create :create_defaults
    
	private
	def create_defaults
		if name == nil
		    s = 'env-' + self.id.to_s
		    self.name = s
		    self.save
		end
	end

	public
	def to_s
		s  = id.to_s + "\t"
		s += name + "\t"
		s += template.to_s + "\t"
		s += node + "\t"
		s += databags.to_s + "\t"
	end


	def updateNode node_path

		if node_path != nil
			self.node = node_path
			self.save
		else
			puts "BAD PATH"
		end
	end

	def setDatabag databags_path
		if databags_path != nil
			self.databags = databags_path
			self.save
		else
			puts "BAD PATH"
		end
	end

	public
	def clone
		envcopy = Enviroment.create(:template=> self.template, :node=> self.node, :databags=> self.databags)
	end

	public
	def self.getEnvById env_id
		if Enviroment.exists?(:id => env_id)
			env=Enviroment.first(:conditions=>{:id=>env_id})
			return env				
		else
			puts 'Can\'t find the enviroment with id: ' + env_id + ' in the database'
			return nil
		end
	end

	public
	def self.getEnvByName env_name
		if Enviroment.exists?(:name =>  env_name)
			env=Enviroment.first(:conditions=>{:name=> env_name})
			return env					
		else
			puts 'Can\'t find the enviroment with name: ' + env_name + ' in the database'
			return nil
		end
	end



end

class CreateSchema < ActiveRecord::Migration

	if !ActiveRecord::Base.connection.table_exists?'cookbooks'
		ActiveRecord::Base.connection.create_table(:cookbooks) do |t|
			t.column :name, :string, :null=>false, :unique=>true
			t.column :path, :string, :default=>CB_DIR
			t.text :recipes
			t.text :recipes_deps
		end
	end

	if !ActiveRecord::Base.connection.table_exists?'roles'
		ActiveRecord::Base.connection.create_table(:roles) do |t|
			t.column :name, :string, :null=>false, :unique=>true
			t.column :path, :string, :default=>ROLE_DIR
			t.text :deps_roles
			t.text :deps_recs

		end
	end

	if !ActiveRecord::Base.connection.table_exists?'enviroments'
		ActiveRecord::Base.connection.create_table(:enviroments) do |t|
			t.column :name, :string, :default=> nil,:unique=>true
			t.column :template, :integer, :null=> false
			t.column :node, :string, :null=> false
			t.column :databags, :string, :default=> nil

		end
	end

end

