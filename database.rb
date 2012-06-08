#!/usr/bin/env ruby

require 'rubygems'
require 'active_record'
require 'check_deps.rb'



CONFIG_FILE = 'oneenv.cnf'

begin
	CONFIG = YAML.load_file(CONFIG_FILE)
	CB_DIR = File.expand_path(CONFIG['default_cb_dir'])
	ROLE_DIR = File.expand_path(CONFIG['default_role_dir'])
rescue Errno::ENOENT => notfound
	puts "Not Found oneenv.cnf"
	exit
rescue  => badargument
	puts "Bad argument in oneenv.conf"
	exit 

end




ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "oneenv.db")

class Cookbook < ActiveRecord::Base
	validates_uniqueness_of :name
	#has_and_belongs_to_many :enviroments, :uniq => true
	serialize :recipes, Array
	serialize :recipes_deps, Hash

	public
	def to_s
		s  = id.to_s + "\t"
		s += name + "\t\t\t"
		s += recipes.length.to_s + "\t"
		#s += recipes_deps.length
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
		#puts r_path
		recs = Dir.entries(r_path)
		#puts recs
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
			#puts cont
			# es cookbook si incluye un archivo metadata.rb
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
			puts 'Can\'t find the cookbook with id: ' + cb_id
			return nil
		end
	end

	public
	def self.getCookbookByName cb_name
		if Cookbook.exists?(:name => cb_name)
			cb=Cookbook.first(:conditions=>{:name=>cb_name})
			return cb					
		else
			puts 'Can\'t find the cookbook with name: ' + cb_name
			return nil
		end
	end

	


end


class Role < ActiveRecord::Base
    validates_uniqueness_of :name
    #has_and_belongs_to_many :enviroments, :uniq => true
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

					# leemos el run_list
					if File.extname(r_name) == ".rb"
						rdeps = get_ruby_runl(r_path)
						r_name = File.basename(r_name, ".rb")
					end
					if File.extname(r_name) == ".json"
						rdeps = get_json_runl(r_path)
						r_name = File.basename(r_name, ".json")
					end	

					#dividimos en recetas y roles
					roles_list = []
					recs_list = []
					rdeps.each do |d|
						if d.start_with?('role')
							d = d[5..-2]	#toma solo el interior
							roles_list.push d
						end
						if d.start_with?('recipe')
							d = d[7..-2]	#toma solo el interior
							recs_list.push d
						end
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

	def self.get_filename rname
		rfile = first(:conditions=>{:name=>rname}).path
		rfile = File.basename(rfile)
		rfile
	end

end

class Enviroment < ActiveRecord::Base

	validates_uniqueness_of :name
	after_create :create_defaults
	#has_and_belongs_to_many :cookbooks, :uniq => true
	#has_and_belongs_to_many :roles, :uniq => true
    
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
			puts 'Can\'t find the enviroment with id: ' + env_id
			return nil
		end
	end

	public
	def self.getEnvByName env_name
		if Enviroment.exists?(:name =>  env_name)
			env=Enviroment.first(:conditions=>{:name=> env_name})
			return env					
		else
			puts 'Can\'t find the enviroment with name: ' + env_name
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
			#t.column :enviroments, :enviroment
		end
	end

	if !ActiveRecord::Base.connection.table_exists?'roles'
		ActiveRecord::Base.connection.create_table(:roles) do |t|
			t.column :name, :string, :null=>false, :unique=>true
			t.column :path, :string, :default=>ROLE_DIR
			t.text :deps_roles
			t.text :deps_recs
			#t.column :enviroments, :enviroment
		end
	end

	if !ActiveRecord::Base.connection.table_exists?'enviroments'
		ActiveRecord::Base.connection.create_table(:enviroments) do |t|
			t.column :name, :string, :default=> nil,:unique=>true
			t.column :template, :integer, :null=> false
			t.column :node, :string, :null=> false
			#t.column :solo_path, :string, :default=>SOLO_DIR
			t.column :databags, :string, :default=> nil
			#t.column :roles, :role
			#t.column :cookbooks, :cookbook
		end
	end

end

