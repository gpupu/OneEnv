#!/usr/bin/env ruby

require 'rubygems'
require 'active_record'
require 'check_deps.rb'



CONFIG_FILE = 'oneenv.cnf'

begin
	CONFIG = YAML.load_file(CONFIG_FILE)
	# TODO Cuidado con esto!! ¿mantiene valor si se cambia el archivo de configuración?
	CB_DIR = File.expand_path(CONFIG['default_cb_dir'])
	ROLE_DIR = File.expand_path(CONFIG['default_role_dir'])
rescue Errno::ENOENT => notfound
	puts "Not Found oneenv.cnf"
	exit
rescue  => badargument
	puts "Bad argument in oneenv.conf"
	exit 

end



# get active record set up
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "oneenv.db")



class Cookbook < ActiveRecord::Base
    validates_uniqueness_of :name
    has_and_belongs_to_many :enviroments, :uniq => true
    serialize :recipes, Array
	serialize :recipes_deps, Hash



	public
	def to_s
		s  = id.to_s + "\t"
		s += name + "\t\t\t"
		#s += path + "\t"
		s += recipes.length.to_s + "\t"
		s += recipes_deps.length.to_s
		s
	end

	public
    def self.cb_create cb_name , cb_path
        if cb_path == nil
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
					create(:name => cb_name, :path => cb_path, :recipes => get_recipes(source), :recipes_deps=>find_deps2(source))
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
			puts 'Can\'t find the cookbook: ' + cb_id
			return nil
		end
	end

	public
	def self.getCookbookByName cb_name
		if Cookbook.exists?(:name => cb_name)
			cb=Cookbook.first(:conditions=>{:name=>cb_name})
			return cb					
		else
			puts 'Can\'t find the cookbook: ' + cb_name
			return nil
		end
	end

	public 
	def self.update cb
		cb.recipes = Cookbook.get_recipes(cb.path)
		cb.save
	end
		
	public
	def self.view cb
		if !cb.nil?
			s  = "NAME:\t" + cb.name + "\n"
			s += "PATH:\t" + cb.path + "\n"

			s += "RECIPES:\t" 
				cb.recipes.each{|r| s += "\n " + r }
			s += "DEPENDENCIES:\t" 
				cb.deps.each{|r| s += "\n " + r }
			s += "\n"
		else
			s +='Can\'t find the cookbook ' + cb_name
		end
		s
	end


end




class Role < ActiveRecord::Base
    validates_uniqueness_of :name
    has_and_belongs_to_many :enviroments, :uniq => true
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

        if r_path == nil
			isextern = false
			source=ROLE_DIR + '/' + r_name
			dest=ROLE_DIR
		else
			isextern=true
			source = r_path + '/' + r_name
			dest=ROLE_DIR
        end

		if !exists?(:name=>r_name)
			r_path = File.expand_path(r_path)
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
					puts rdeps
					
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
    has_and_belongs_to_many :cookbooks, :uniq => true
	has_and_belongs_to_many :roles, :uniq => true
    
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

	public
	def self.view_enviroment id
		env=first(:conditions => {:id => id})
		if !env.nil?
			s  = "ID:\t" + env.id.to_s + "\n"
			s += "NAME:\t" + env.name + "\n"
			s += "BASE TEMPLATE:\t" + env.template.to_s + "\n"
			if env.databags != nil
				s += "DATABAG DIR:\t" + env.databags + "\n" 
			end
			s += "COOKBOOKS: " + "\t"
				env.cookbooks.each{|cb| s += ", " + cb.name }
			s += "\n"
			s += "ROLES:" + "\t"
				env.roles.each{|r| s += ", " + r.name}
			s += "\n"
		else
			s +='Can\'t find the enviroment ' + id.to_s
		end
		s
	end

	public
	def clone
		envcopy = Enviroment.create(:template=> self.template, :node=> self.node, :databags=> self.databags)
	end

end

class CreateSchema < ActiveRecord::Migration

if !table_exists?(:cookbooks)
    create_table(:cookbooks) do |t|
        t.column :name, :string, :null=>false, :unique=>true
        t.column :path, :string, :default=>CB_DIR
        t.text :recipes
		t.text :recipes_deps
        #t.column :enviroments, :enviroment
    end
end

if !table_exists?(:roles)
	create_table(:roles) do |t|
		t.column :name, :string, :null=>false, :unique=>true
        t.column :path, :string, :default=>ROLE_DIR
		t.text :deps_roles
		t.text :deps_recs
        #t.column :enviroments, :enviroment
	end
end

if !table_exists?(:enviroments)
    create_table(:enviroments) do |t|
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

